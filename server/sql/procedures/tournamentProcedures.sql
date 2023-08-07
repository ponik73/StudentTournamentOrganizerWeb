\! echo "--------------------------------------------------------";
\! echo "Tournament procedures";

delimiter //

-- create tournament
DROP PROCEDURE IF EXISTS CreateTournament;
CREATE PROCEDURE CreateTournament (
    in _tnmntName VARCHAR(50),
    in _gameType VARCHAR(50),
    in _maxParticipants smallint,
    in _isForTeams tinyint,
    in _tnmntStart datetime,
    in _creatorID int,
    in _minPlayersPerGame smallint
)
BEGIN
    INSERT INTO Tournaments (tnmntName, gameType, maxParticipants, isForTeams, tnmntStart, creatorID, minPlayersPerGame) 
    VALUES (_tnmntName, _gameType, _maxParticipants, _isForTeams, _tnmntStart, _creatorID, _minPlayersPerGame);
END//

-- get all tournaments with participants
DROP PROCEDURE IF EXISTS GetAllTournaments;
CREATE PROCEDURE GetAllTournaments()
BEGIN
    SELECT Tournaments.*, count(Participants.idTP) as participantsCount 
    FROM Tournaments 
    LEFT JOIN Participants ON (Tournaments.tnmntID = Participants.tnmntID) 
    GROUP BY Tournaments.tnmntID 
    ORDER BY Tournaments.tnmntStart
    LIMIT 50;
END//

-- get tournament by id
DROP PROCEDURE IF EXISTS GetTournamentById;
CREATE PROCEDURE GetTournamentById(
    in _id int
)
BEGIN
    SELECT Tournaments.*, count(Participants.idTP) as participantsCount 
    FROM Tournaments LEFT JOIN Participants ON (Tournaments.tnmntID = Participants.tnmntID) 
    WHERE Tournaments.tnmntID = _id 
    GROUP BY Tournaments.tnmntID;
END//

-- Gets all tournament participants
DROP PROCEDURE IF EXISTS GetTnmntsParticipants;
CREATE PROCEDURE GetTnmntsParticipants (
    in _tnmntID INTEGER
)
BEGIN
    DECLARE _isForTeams TINYINT;

    SET _isForTeams := (SELECT isForTeams FROM Tournaments WHERE tnmntID = _tnmntID);

    IF (_isForTeams = 0) THEN
        -- Tournament for users
        SELECT Participants.idTP, Users.username 
        FROM Users
        LEFT JOIN Participants ON (Participants.userID = Users.userID)
        WHERE Participants.tnmntID = _tnmntID
        ORDER BY Participants.idTP;
    ELSE
        -- Tournament for teams
        SELECT Participants.idTP, Teams.teamName 
        FROM Teams
        LEFT JOIN Participants ON (Participants.teamID = Teams.teamID)
        WHERE Participants.tnmntID = _tnmntID
        ORDER BY Participants.idTP;
    END IF;
END//

-- approve tournament
DROP PROCEDURE IF EXISTS ApproveTournament;
CREATE PROCEDURE ApproveTournament (
    in _tnmntID INTEGER
)
BEGIN
    UPDATE Tournaments SET isApproved = 1 WHERE Tournaments.tnmntID = _tnmntID;
END//

-- delete tournament
DROP PROCEDURE IF EXISTS DeleteTournament;
CREATE PROCEDURE DeleteTournament (
    in _tnmntID INTEGER
)
BEGIN
    DELETE FROM Tournaments WHERE tnmntID = _tnmntID;
END//

delimiter ;
