\! echo "--------------------------------------------------------";
\! echo "Match procedures";

delimiter //

-- Creates match
DROP PROCEDURE IF EXISTS CreateMatch;
CREATE PROCEDURE CreateMatch (
    in _matchStart DATETIME,
    in _partOneId INTEGER,
    in _partTwoId INTEGER,
    in _tnmntRound SMALLINT,
    in _tnmntID INTEGER
)
BEGIN
    IF _partOneId != 0 AND _partTwoId != 0 THEN
        INSERT INTO Matches (matchStart, partOneID, partTwoID, tnmntRound, tnmntID)
        VALUES (_matchStart, _partOneId, _partTwoId, _tnmntRound, _tnmntID);
    ELSEIF _partOneId != 0 THEN
        INSERT INTO Matches (matchStart, partOneID, tnmntRound, tnmntID)
        VALUES (_matchStart, _partOneId, _tnmntRound, _tnmntID);
    ELSEIF _partTwoId != 0 THEN
        INSERT INTO Matches (matchStart, partTwoID, tnmntRound, tnmntID)
        VALUES (_matchStart, _partTwoId, _tnmntRound, _tnmntID);
    ELSE
        INSERT INTO Matches (matchStart, tnmntRound, tnmntID)
        VALUES (_matchStart, _tnmntRound, _tnmntID);
    END IF;
END//

-- Gets all matches
DROP PROCEDURE IF EXISTS GetAllMatches;
CREATE PROCEDURE GetAllMatches ()
BEGIN
    SELECT * FROM Matches;
END//

-- Gets match by id
DROP PROCEDURE IF EXISTS GetMatchByID;
CREATE PROCEDURE GetMatchByID (
    in _matchId INTEGER
)
BEGIN
    SELECT * FROM Matches WHERE matchID = _matchId;
END//

-- Gets tournaments matches
DROP PROCEDURE IF EXISTS GetMatchesByTnmntID;
CREATE PROCEDURE GetMatchesByTnmntID (
    in _tnmntID INTEGER
)
BEGIN
    SELECT * FROM Matches WHERE tnmntID = _tnmntID;
END//

-- Deletes match
DROP PROCEDURE IF EXISTS DeleteMatch;
CREATE PROCEDURE DeleteMatch (
    in _matchId INTEGER
)
BEGIN
    DELETE FROM Matches WHERE matchID = _matchId;
END//

-- Delete all matches from tournament
DROP PROCEDURE IF EXISTS DeleteMatchesFromTournament;
CREATE PROCEDURE DeleteMatchesFromTournament (
    in _tnmntID INTEGER
)
BEGIN
    DELETE FROM Matches WHERE tnmntID = _tnmntID;
END//

-- Finish match
DROP PROCEDURE IF EXISTS FinishMatch;
CREATE PROCEDURE FinishMatch (
    in _matchID INTEGER
)
BEGIN
    DECLARE _matchRound INTEGER;
    DECLARE _partOneScore INTEGER;  -- only help var
    DECLARE _partTwoScore INTEGER;  -- only help var
    DECLARE _winnerID INTEGER;
    DECLARE _tnmntID INTEGER;
    DECLARE _matchPosition INTEGER;

    DECLARE _nextRound INTEGER;
    DECLARE _nextMatchPosition INTEGER;
    DECLARE _nextMatchID INTEGER;

    UPDATE Matches SET isFinished = 1 WHERE matchID = _matchID;

    SET _matchRound = (SELECT tnmntRound FROM Matches WHERE matchID = _matchID);

    IF _matchRound != 1 THEN

        -- Setting winner ID
        CALL GetMatchWinner(_matchID, _winnerID);

        -- Setting tournament ID
        SET _tnmntID = (SELECT tnmntID FROM Matches WHERE matchID = _matchID);

        -- Setting current match round position
        CALL GetMatchPositionInTnmntRound(_tnmntID, _matchRound, _matchID, _matchPosition);

        -- Setting next round
        SET _nextRound = _matchRound / 2;

        -- Setting next position
        SET _nextMatchPosition = CEIL(_matchPosition / 2);

        -- Setting next match ID
        CALL GetMatchIdFromTournamentRoundPosition(_tnmntID, _nextRound, _nextMatchPosition, _nextMatchID);

        -- Adding winner to the next match
        CALL AddParticipantToMatch(_winnerID, _nextMatchID);
    END IF;
END//

-- Gets matches from tournament round with indexes
DROP PROCEDURE IF EXISTS GetTournamentRoundMatchesWithIndex;
CREATE PROCEDURE GetTournamentRoundMatchesWithIndex (
    in _tnmntID INTEGER,
    in _round INTEGER
)
BEGIN
    SELECT Matches.*,
	   (SELECT COUNT(*) FROM Matches as m WHERE m.matchID <= Matches.matchID AND tnmntID = _tnmntID AND tnmntRound = _round ORDER BY m.matchID) AS position
    FROM Matches
    WHERE tnmntID = _tnmntID AND tnmntRound = _round
    ORDER BY Matches.matchID;
END//

-- Gets position of match in tournament round
DROP PROCEDURE IF EXISTS GetMatchPositionInTnmntRound;
CREATE PROCEDURE GetMatchPositionInTnmntRound (
    in _tnmntID INTEGER,
    in _tnmntRound INTEGER,
    in _matchID INTEGER,
    out _matchPos INTEGER
)
BEGIN
    SET _matchPos = (SELECT (SELECT COUNT(*) FROM Matches as mLoc WHERE mLoc.matchID <= mGlob.matchID AND mLoc.tnmntID = _tnmntID AND mLoc.tnmntRound = _tnmntRound ORDER BY mLoc.matchID)
    FROM Matches as mGlob
    WHERE matchID = _matchID
    ORDER BY mGlob.matchID);
END//

-- Gets match id of match at the position in tournament round
DROP PROCEDURE IF EXISTS GetMatchIdFromTournamentRoundPosition;
CREATE PROCEDURE GetMatchIdFromTournamentRoundPosition (
    in _tnmntID INTEGER,
    in _tnmntRound INTEGER,
    in _position INTEGER,
    out _matchID INTEGER
)
BEGIN
    SET _matchID = (SELECT matchID
    FROM Matches as mGlob
    WHERE (SELECT COUNT(*) FROM Matches as mLoc WHERE mLoc.matchID <= mGlob.matchID AND mLoc.tnmntID = _tnmntID AND mLoc.tnmntRound = _tnmntRound ORDER BY mLoc.matchID) = _position
    AND mGlob.tnmntID = _tnmntID AND mGlob.tnmntRound = _tnmntRound);
END//

-- Get match winner by score
DROP PROCEDURE IF EXISTS GetMatchWinner;
CREATE PROCEDURE GetMatchWinner (
    in _matchID INTEGER,
    out _winnerID INTEGER
)
BEGIN
    DECLARE scoreOne INTEGER;
    DECLARE scoreTwo INTEGER;

    IF (SELECT partTwoID FROM Matches WHERE matchID = _matchID) IS NULL THEN
        SET _winnerID = (SELECT partOneID FROM Matches WHERE matchID = _matchID);
    ELSE
        SET scoreOne := (SELECT partOneScore FROM Matches WHERE matchID = _matchID);
        SET scoreTwo := (SELECT partTwoScore FROM Matches WHERE matchID = _matchID);

        IF (scoreOne IS NOT NULL AND scoreTwo IS NOT NULL) THEN
            IF (scoreOne > scoreTwo) THEN
                SET _winnerID = (SELECT partOneID FROM Matches WHERE matchID = _matchID);
            ELSEIF (scoreOne < scoreTwo) THEN
                SET _winnerID = (SELECT partTwoID FROM Matches WHERE matchID = _matchID);
            END IF;
        END IF;
    END IF;
END//

-- Add participant to the match
DROP PROCEDURE IF EXISTS AddParticipantToMatch;
CREATE PROCEDURE AddParticipantToMatch (
    in _participantID INTEGER,
    in _matchID INTEGER
)
BEGIN
    IF (SELECT partOneID FROM Matches WHERE matchID = _matchID) IS NULL THEN
        UPDATE Matches SET partOneID = _participantID WHERE matchID = _matchID;
    ELSE
        UPDATE Matches SET partTwoID = _participantID WHERE matchID = _matchID;
    END IF;
END//

delimiter ;
