\! echo "--------------------------------------------------------";
\! echo "User procedures";

delimiter //

-- approve user
DROP PROCEDURE IF EXISTS ApproveUser;
CREATE PROCEDURE ApproveUser (
    in _userID INTEGER
)
BEGIN
    UPDATE Users SET isApproved = 1 WHERE Users.userID = _userID;
END//

-- delete user
DROP PROCEDURE IF EXISTS DeleteUser;
CREATE PROCEDURE DeleteUser (
    in _userID INTEGER
)
BEGIN
    DELETE FROM Users WHERE userID = _userID;
END//

-- get all users
DROP PROCEDURE IF EXISTS GetAllUsers;
CREATE PROCEDURE GetAllUsers ()
BEGIN
    SELECT userID, username, created, isAdmin, isApproved 
    FROM Users 
    LIMIT 50;
END//

-- get user by id
DROP PROCEDURE IF EXISTS GetUserById;
CREATE PROCEDURE GetUserById (
    in _userID int
)
BEGIN
    DECLARE _matPlayed INTEGER;
    DECLARE _matWon INTEGER;
    DECLARE _matLost INTEGER;

    CALL GetUsersMatchesPlayed(_userID, _matPlayed);
    CALL GetUserMatchesWon(_userID, _matWon);
    CALL GetUserMatchesLost(_userID, _matLost);

    SELECT Users.userID, Users.username, Users.created, Users.isAdmin, Users.isApproved, _matPlayed AS matPlayed, _matWon AS matWon, _matLost AS matLost
    FROM Users
    LEFT JOIN Participants ON (Users.userID = Participants.userID)
    LEFT JOIN Matches ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID)
    WHERE Users.userID = _userID
    GROUP BY Users.userID;
END//

-- get user matches number
DROP PROCEDURE IF EXISTS GetUsersMatchesPlayed;
CREATE PROCEDURE GetUsersMatchesPlayed (
    in _userID INTEGER,
    out _matPlayed INTEGER
)
BEGIN
    SET _matPlayed = (SELECT COUNT(*) 
    FROM Matches 
    LEFT JOIN Participants ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID) 
    WHERE Participants.userID = _userID AND Matches.isFinished = 1 AND Matches.partTwoID IS NOT NULL
    GROUP BY Matches.matchID);

    IF _matPlayed IS NULL THEN
        SET _matPlayed = 0;
    END IF;
END//

-- get user won matches number
DROP PROCEDURE IF EXISTS GetUserMatchesWon;
CREATE PROCEDURE GetUserMatchesWon (
    in _userID INTEGER,
    out _matWon INTEGER
)
BEGIN
    SET _matWon = (SELECT COUNT(*) 
    FROM Matches 
    LEFT JOIN Participants ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID) 
    WHERE Participants.userID = _userID 
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

-- get user lost matches number
DROP PROCEDURE IF EXISTS GetUserMatchesLost;
CREATE PROCEDURE GetUserMatchesLost (
    in _userID INTEGER,
    out _matLost INTEGER
)
BEGIN
    SET _matLost = (SELECT COUNT(*) 
    FROM Matches 
    LEFT JOIN Participants ON (Participants.idTP = Matches.partOneID OR Participants.idTP = Matches.partTwoID) 
    WHERE Participants.userID = _userID 
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

-- get user's teams
DROP PROCEDURE IF EXISTS GetUsersTeams;
CREATE PROCEDURE GetUsersTeams (
    in _userID int
)
BEGIN
    SELECT Teams.*
    FROM Teams
    LEFT JOIN TeamPlayers ON (Teams.teamID = TeamPlayers.teamID)
    WHERE TeamPlayers.userID = _userID;
END//

-- validate user
DROP PROCEDURE IF EXISTS GetUserForValidation;
CREATE PROCEDURE GetUserForValidation (
    in _username VARCHAR(50)
)
BEGIN
    SELECT *
    FROM Users
    WHERE Users.username = _username;
END//

-- is user admin
DROP PROCEDURE IF EXISTS IsUserAdmin;
CREATE PROCEDURE IsUserAdmin (
    in _userID INTEGER
)
BEGIN
    SELECT isAdmin
    FROM Users
    WHERE Users.userID = _userID;
END//

-- register user
DROP PROCEDURE IF EXISTS RegisterUser;
CREATE PROCEDURE RegisterUser (
    in _username VARCHAR(50),
    in _pwd VARCHAR(255)
)
BEGIN
    INSERT INTO Users (username, pwd) VALUES (_username, _pwd);
END//

-- register user for tournament
DROP PROCEDURE IF EXISTS RegisterUserForTournament;
CREATE PROCEDURE RegisterUserForTournament (
    in _userID int,
    in _tnmntID int
    )
BEGIN
    INSERT INTO Participants (tnmntID, userID) VALUES (_tnmntID, _userID);
END//

-- set user as admin
DROP PROCEDURE IF EXISTS SetUserAsAdmin;
CREATE PROCEDURE SetUserAsAdmin (
    in _userID INTEGER
)
BEGIN
    UPDATE Users SET isAdmin = 1, isApproved = 1 WHERE Users.userID = _userID;
END//

-- user joins team
DROP PROCEDURE IF EXISTS UserJoinsTeam;
CREATE PROCEDURE UserJoinsTeam (
    in _userID int,
    in _teamID int
)
BEGIN
    INSERT INTO TeamPlayers (teamID, userID) VALUES (_teamID, _userID);
END//

delimiter ;
