\! echo "--------------------------------------------------------";
\! echo "Match triggers";

DELIMITER //

-- can not create match in not approved tournament
DROP TRIGGER IF EXISTS notApprovedTournamentCannotCreateMatchTrg;
CREATE TRIGGER notApprovedTournamentCannotCreateMatchTrg
BEFORE INSERT ON Matches
FOR EACH ROW
BEGIN
    DECLARE tnmntApproved tinyint; 
    
    SET tnmntApproved := (SELECT isApproved FROM Tournaments WHERE Tournaments.tnmntID = NEW.tnmntID);

    IF (tnmntApproved = 0) THEN
        signal sqlstate '45000' set message_text = 'Can not create match in not approved tournament';
    END IF;
END//

-- Both participants in match must have same tnmntID as match
DROP TRIGGER IF EXISTS checksTnmntIdsForMatchAndParticipantsTrg;
CREATE TRIGGER checksTnmntIdsForMatchAndParticipantsTrg
BEFORE INSERT ON Matches
FOR EACH ROW
BEGIN
    DECLARE _partOneTnmntId INTEGER;
    DECLARE _partTwoTnmntId INTEGER;

    IF (NEW.partOneID IS NOT NULL) THEN
        SET _partOneTnmntId := (SELECT tnmntID FROM Participants WHERE Participants.idTP = NEW.partOneID);
    ELSEIF (NEW.partTwoID IS NOT NULL) THEN
        SET _partTwoTnmntId := (SELECT tnmntID FROM Participants WHERE Participants.idTP = NEW.partTwoID);
    END IF;

    IF (_partOneTnmntId IS NOT NULL AND _partOneTnmntId != NEW.tnmntID OR _partTwoTnmntId IS NOT NULL AND _partTwoTnmntId != NEW.tnmntID) THEN
        signal sqlstate '45000' set message_text = 'Participant in match has different tnmntID as tournament';
    END IF;
END//

-- One participant can not be twice in match
DROP TRIGGER IF EXISTS checksIfParticipantIsNotTwiceInMatchTrg;
CREATE TRIGGER checksIfParticipantIsNotTwiceInMatchTrg
BEFORE INSERT ON Matches
FOR EACH ROW
BEGIN
    IF (NEW.partOneID = NEW.partTwoID) THEN
        signal sqlstate '45000' set message_text = 'Participant can not be twice in one match';
    END IF;
END//

-- One participant can not be twice in round
DROP TRIGGER IF EXISTS checksIfParticipantIsNotTwiceInRoundTrg;
CREATE TRIGGER checksIfParticipantIsNotTwiceInRoundTrg
BEFORE INSERT ON Matches
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Matches
        WHERE Matches.tnmntRound = NEW.tnmntRound 
        AND Matches.tnmntID = NEW.tnmntID 
        AND (Matches.partOneID = NEW.partOneID OR Matches.partTwoID = NEW.partTwoID OR Matches.partOneID = NEW.partTwoID OR Matches.partTwoID = NEW.partOneID)
    ) THEN
        signal sqlstate '45000' set message_text = 'Participant can not be twice in one tournament round';
    END IF;
END//

-- Can not be more matches in round than round number
DROP TRIGGER IF EXISTS strictMatchesPerRoundInTnmntTrg;
CREATE TRIGGER strictMatchesPerRoundInTnmntTrg
BEFORE INSERT ON Matches
FOR EACH ROW
BEGIN
    DECLARE matchesInRound INTEGER;

    SET matchesInRound := (SELECT COUNT(*) FROM Matches WHERE Matches.tnmntID = NEW.tnmntID AND Matches.tnmntRound = NEW.tnmntRound);

    IF (matchesInRound >= NEW.tnmntRound) THEN
        signal sqlstate '45000' set message_text = 'Can not create more matches for tournament round';
    END IF;
END//

-- Finished match can not be draw and score empty
DROP TRIGGER IF EXISTS matchCanNotFinishAsDrawTrg;
CREATE TRIGGER matchCanNotFinishAsDrawTrg
BEFORE UPDATE ON Matches
FOR EACH ROW
BEGIN
    DECLARE firstScore INTEGER;
    DECLARE secondScore INTEGER;

    IF NEW.partOneID IS NOT NULL AND NEW.partTwoID IS NOT NULL THEN
        IF NEW.partOneScore IS NOT NULL THEN
            SET firstScore = NEW.partOneScore;
        ELSEIF OLD.partOneScore IS NOT NULL THEN
            SET firstScore = OLD.partOneScore;
        ELSEIF NEW.isFinished = 1 THEN
            signal sqlstate '45000' set message_text = 'Score on first player can not be null on match finish';
        END IF;

        IF NEW.partTwoScore IS NOT NULL THEN
            SET secondScore = NEW.partTwoScore;
        ELSEIF OLD.partTwoScore IS NOT NULL THEN
            SET secondScore = OLD.partTwoScore;
        ELSEIF NEW.isFinished = 1 THEN
            signal sqlstate '45000' set message_text = 'Score on second player can not be null on match finish';
        END IF;

        IF (NEW.isFinished = 1 AND firstScore = secondScore) THEN
            signal sqlstate '45000' set message_text = "Match can't finish as draw";
        END IF;
    END IF;
END//

-- Move winner to next round after match is finished
-- DROP TRIGGER IF EXISTS moveWinnerToNextRoundAfterFinishMatchTrg;
-- CREATE TRIGGER moveWinnerToNextRoundAfterFinishMatchTrg
-- AFTER UPDATE ON Matches
-- FOR EACH ROW
-- BEGIN
--     DECLARE _winnerID INTEGER;
--     DECLARE matchPos INTEGER;
--     DECLARE nextRound INTEGER;
--     DECLARE nextPosition INTEGER;
--     DECLARE nextMatchId INTEGER;

--     -- Return trigger if match is not finished or is final match
--     IF (NEW.isFinished = 1 AND NEW.tnmntRound != 1) THEN
--         -- SET _winnerID = (CALL GetMatchWinner(NEW.matchID));

--         -- IF _winnerID IS NULL THEN
--         --     signal sqlstate '45000' set message_text = 'Fail in deciding match winner';
--         -- END IF;

--         -- sets winner id
--         IF (NEW.partTwoID IS NULL) THEN
--             SET _winnerID = NEW.partOneID;
--         ELSEIF (NEW.partOneScore > NEW.partTwoScore) THEN
--             SET _winnerID = NEW.partOneID;
--         ELSE
--             SET _winnerID = NEW.partTwoID;
--         END IF;

--         -- CALL GetTournamentRoundMatchesWithIndex(NEW.tnmntID, NEW.tnmntRound);

--         -- match position in current round
--         -- SET matchPos = (CALL GetMatchPositionInTnmntRound(NEW.tnmntID, NEW.tnmntRound, NEW.matchID));
--         SET matchPos = (SELECT (SELECT COUNT(*) FROM Matches as mLoc WHERE mLoc.matchID <= mGlob.matchID 
--             AND mLoc.tnmntID = NEW.tnmntID AND mLoc.tnmntRound = NEW.tnmntRound ORDER BY mLoc.matchID) AS position
--             FROM Matches as mGlob
--             WHERE matchID = NEW.matchID
--             ORDER BY mGlob.matchID);

--         SET nextRound = NEW.tnmntRound / 2;

--         SET nextPosition = CEIL(matchPos / 2);

--         -- SET nextMatchId = (CALL GetMatchIdFromTournamentRoundPosition(NEW.tnmntID, nextRound, nextPosition));
--         SET nextMatchId = (SELECT matchID
--             FROM Matches as mGlob
--             WHERE (SELECT COUNT(*) FROM Matches as mLoc WHERE mLoc.matchID <= mGlob.matchID 
--             AND mLoc.tnmntID = NEW.tnmntID AND mLoc.tnmntRound = nextRound ORDER BY mLoc.matchID) = nextPosition);

--         CALL AddParticipantToMatch(_winnerID, nextMatchId);
--         -- IF (SELECT partOneID FROM Matches WHERE matchID = nextMatchId) IS NULL THEN
--         --     CALL AddParticipantToMatch(_winnerID, _nextMatchId);
--         --     -- UPDATE Matches SET partOneID = _winnerID WHERE matchID = nextMatchId;
--         -- ELSE
--         --     CALL AddParticipantToMatch(_winnerID, _nextMatchId);
--         --     UPDATE Matches SET partTwoID = _winnerID WHERE matchID = nextMatchId;
--         -- END IF;
--     END IF;
-- END//

DELIMITER ;
