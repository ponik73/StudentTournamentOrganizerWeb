\! echo "--------------------------------------------------------";
\! echo "Team procedures";

delimiter //

-- approve team
DROP PROCEDURE IF EXISTS ApproveTeam;
CREATE PROCEDURE ApproveTeam (
    in _teamID INTEGER
)
BEGIN
    UPDATE Teams SET isApproved = 1 WHERE Teams.teamID = _teamID;
END//

-- create team
DROP PROCEDURE IF EXISTS CreateTeam;
CREATE PROCEDURE CreateTeam (
    in _leaderId int,
    in _teamName VARCHAR(50)
)
BEGIN
    INSERT INTO Teams (leaderID, teamName) VALUES (_leaderId, _teamName);
END//

-- delete team
DROP PROCEDURE IF EXISTS DeleteTeam;
CREATE PROCEDURE DeleteTeam (
    in _teamID INTEGER
)
BEGIN
    DELETE FROM Teams WHERE teamID = _teamID;
END//

-- get all teams with participants count
DROP PROCEDURE IF EXISTS GetAllTeams;
CREATE PROCEDURE GetAllTeams()
BEGIN
    SELECT Teams.*, COUNT(TeamPlayers.id) as membersCount
    FROM Teams
    LEFT JOIN TeamPlayers ON (Teams.teamID = TeamPlayers.teamID) 
    GROUP BY Teams.teamID
    LIMIT 50;
END//

-- get team with participants count by id
DROP PROCEDURE IF EXISTS GetTeamById;
CREATE PROCEDURE GetTeamById (
    in _teamID INTEGER
)
BEGIN
    DECLARE _matPlayed INTEGER;
    DECLARE _matWon INTEGER;
    DECLARE _matLost INTEGER;

    CALL GetUsersMatchesPlayed(_userID, _matPlayed);
    CALL GetUserMatchesWon(_userID, _matWon);
    CALL GetUserMatchesLost(_userID, _matLost);

    SELECT Teams.*, COUNT(TeamPlayers.id) as membersCount, _matPlayed as matPlayed, _matWon as matWon, _matLost as matLost
    FROM Teams
    LEFT JOIN TeamPlayers ON (Teams.teamID = TeamPlayers.teamID) 
    WHERE Teams.teamID = _teamID 
    GROUP BY Teams.teamID;
END//

-- get team matches number
DROP PROCEDURE IF EXISTS GetTeamMatchesPlayed;
CREATE PROCEDURE GetTeamMatchesPlayed (
    in _teamID INTEGER,
    out _matPlayed INTEGER
)
BEGIN
    SET _matPlayed = (SELECT COUNT(*) 
    FROM Matches 
    LEFT JOIN Participants ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID) 
    WHERE Participants.teamID = _teamID AND Matches.isFinished = 1 AND Matches.partTwoID IS NOT NULL
    GROUP BY Matches.matchID);

    IF _matPlayed IS NULL THEN
        SET _matPlayed = 0;
    END IF;
END//

-- get team won matches number
DROP PROCEDURE IF EXISTS GetTeamMatchesWon;
CREATE PROCEDURE GetTeamMatchesWon (
    in _teamID INTEGER,
    out _matWon INTEGER
)
BEGIN
    SET _matWon = (SELECT COUNT(*) 
    FROM Matches 
    LEFT JOIN Participants ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID) 
    WHERE Participants.teamID = _teamID 
        AND Matches.isFinished = 1 
        AND Matches.partTwoID IS NOT NULL
        AND (
            (Matches.partOneID = Participants.idTP AND Matches.partOneScore > Matches.partTwoScore) 
            OR (Matches.partTwoID = Participants.idTP AND Matches.partOneScore < Matches.partTwoScore))
    GROUP BY Matches.matchID);

    IF _matWon IS NULL THEN
        SET _matWon = 0;
    END IF;
END//

-- get team lost matches number
DROP PROCEDURE IF EXISTS GetTeamMatchesLost;
CREATE PROCEDURE GetTeamMatchesLost (
    in _teamID INTEGER,
    out _matLost INTEGER
)
BEGIN
    SET _matLost = (SELECT COUNT(*) 
    FROM Matches 
    LEFT JOIN Participants ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID) 
    WHERE Participants.teamID = _teamID 
        AND Matches.isFinished = 1 
        AND Matches.partTwoID IS NOT NULL
        AND (
            (Matches.partOneID = Participants.idTP AND Matches.partOneScore < Matches.partTwoScore) 
            OR (Matches.partTwoID = Participants.idTP AND Matches.partOneScore > Matches.partTwoScore))
    GROUP BY Matches.matchID);

    IF _matLost IS NULL THEN
        SET _matLost = 0;
    END IF;
END//

-- register team for tournament
DROP PROCEDURE IF EXISTS RegisterTeamForTournament;
CREATE PROCEDURE RegisterTeamForTournament (
    in _teamID int,
    in _tnmntID int
)
BEGIN
    INSERT INTO Participants (tnmntID, teamID) VALUES (_tnmntID, _teamID);
END//

delimiter ;
