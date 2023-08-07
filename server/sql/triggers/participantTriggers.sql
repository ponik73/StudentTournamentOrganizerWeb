\! echo "--------------------------------------------------------";
\! echo "Participants triggers";

DELIMITER //

-- Checks tournament approvness
DROP TRIGGER IF EXISTS checksTnmntApprovnessTrg;
CREATE TRIGGER checksTnmntApprovnessTrg
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    DECLARE tnmntApprove TINYINT;

    SET tnmntApprove := (SELECT isApproved FROM Tournaments WHERE Tournaments.tnmntID = NEW.tnmntID);

    IF (tnmntApprove = 0) THEN
        signal sqlstate '45000' set message_text = 'Tournament is not approved';
    END IF;
END//

-- Checks if tournament didn't start already
DROP TRIGGER IF EXISTS checksIfTournamentDidntStart;
CREATE TRIGGER checksIfTournamentDidntStart
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Tournaments
        WHERE NEW.tnmntID = Tournaments.tnmntID AND Tournaments.tnmntStart < now()
    ) THEN
        signal sqlstate '45000' set message_text = 'You can not register for tournament after start';
    END IF;
END;//

-- Can not insert both null user and team id or both not null
DROP TRIGGER IF EXISTS checkTournamentUserTeamNulls;
CREATE TRIGGER checkTournamentUserTeamNulls
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    IF NOT (NEW.userID IS NOT NULL XOR NEW.teamID IS NOT NULL)
    THEN
        signal sqlstate '45000' set message_text = 'You must pass userID or teamID and can not pass both';
    END IF;
END;//

-- Participant must be approved
DROP TRIGGER IF EXISTS participantApproveForTournament;
CREATE TRIGGER participantApproveForTournament
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    DECLARE participantApprove INTEGER;
    DECLARE errorMessage VARCHAR(50);

    IF (NEW.userID IS NOT NULL) THEN
        SET participantApprove := (SELECT isApproved FROM Users WHERE Users.userID = NEW.userID);
        SET errorMessage := 'User is not approved';
    ELSE
        SET participantApprove := (SELECT isApproved FROM Teams WHERE Teams.teamID = NEW.teamID);
        SET errorMessage := 'Team is not approved';
    END IF;

    IF participantApprove = 0 THEN
        signal sqlstate '45000' set message_text = errorMessage;
    END IF;
END//

-- Checks if tournament is full
DROP TRIGGER IF EXISTS fullTournamentCheck;
CREATE TRIGGER fullTournamentCheck
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    DECLARE parInTnmnt integer;
    DECLARE tnmntMaxParticipants integer;

    SET parInTnmnt := (select count(*) from Participants where Participants.tnmntID = NEW.tnmntID);
    SET tnmntMaxParticipants := (select maxParticipants from Tournaments where Tournaments.tnmntID = NEW.tnmntID);

    IF parInTnmnt >= tnmntMaxParticipants THEN
        signal sqlstate '45000' set message_text = 'Tournament is full';
    END IF;
END;//

-- Checks if it's user or team tournament
DROP TRIGGER IF EXISTS checksTournamentParticipantsType;
CREATE TRIGGER checksTournamentParticipantsType
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    DECLARE is_team_tournament integer;

    IF (NEW.userID IS NOT NULL) THEN
        SET is_team_tournament := 0;
    ELSE
        SET is_team_tournament := 1;
    END IF;

    IF NOT EXISTS (
        SELECT *
        FROM Tournaments
        WHERE NEW.tnmntID = Tournaments.tnmntID AND is_team_tournament = Tournaments.isForTeams
    ) THEN
        signal sqlstate '45000' set message_text = 'You are registering as wrong participant (user, team)';
    END IF;
END;//

-- trigger checks if minimal players per game in tournament is not above team players in team
DROP TRIGGER IF EXISTS teamMinimalTeamPlayersPerMinimalPlayersPerGameInTnmntTrg;
CREATE TRIGGER teamMinimalTeamPlayersPerMinimalPlayersPerGameInTnmntTrg
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN
    DECLARE teamPlayersCount INTEGER;
    DECLARE tnmntMinimalPlayersPerGame INTEGER;

    -- check only for teams
    IF (NEW.teamID IS NOT NULL) THEN
        SET teamPlayersCount := (SELECT COUNT(*) FROM TeamPlayers WHERE TeamPlayers.teamID = NEW.teamID) + 1;
        SET tnmntMinimalPlayersPerGame := (SELECT minPlayersPerGame FROM Tournaments WHERE Tournaments.tnmntID = NEW.tnmntID);

        IF (teamPlayersCount < tnmntMinimalPlayersPerGame) THEN
            signal sqlstate '45000' set message_text = 'Your team does not have enough members to join this tournament';
        END IF;
    END IF;
END//

DELIMITER ;
