\! echo "--------------------------------------------------------";
\! echo "Team Players triggers";

DELIMITER //

-- leader can not leave team
DROP TRIGGER IF EXISTS permitedTeamLeaderDelete;
CREATE TRIGGER permitedTeamLeaderDelete
BEFORE DELETE ON TeamPlayers
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Teams
        WHERE OLD.teamID = Teams.teamID AND Teams.leaderID = OLD.userID
    ) THEN
        signal sqlstate '45000' set message_text = 'Leader can not leave team';
    END IF;
END//

-- leader can not join team as TeamPlayer
-- DROP TRIGGER IF EXISTS leaderPermittedJoinTrg;
-- CREATE TRIGGER leaderPermittedJoinTrg
-- BEFORE INSERT ON TeamPlayers
-- FOR EACH ROW
-- BEGIN
--     DECLARE _leaderID integer;

--     SET _leaderID := (SELECT leaderID FROM Teams WHERE Teams.teamID = NEW.teamID);

--     IF (_leaderID = NEW.userID) THEN
--         signal sqlstate '45000' set message_text = 'Leader can not join team as team player';
--     END IF;
-- END//

-- Check approvness of user and team
DROP TRIGGER IF EXISTS userTeamApprove;
CREATE TRIGGER userTeamApprove
BEFORE INSERT ON TeamPlayers
FOR EACH ROW
BEGIN
    DECLARE userApproved tinyint;
    DECLARE teamApproved tinyint;
    DECLARE _leaderID integer;

    SET userApproved := (SELECT isApproved FROM Users WHERE Users.userID = NEW.userID);
    SET teamApproved := (SELECT isApproved FROM Teams WHERE Teams.teamID = NEW.teamID);

    SET _leaderID := (SELECT leaderID FROM Teams WHERE Teams.teamID = NEW.teamID);

    -- Leader could be added to his own team even when team is not approved
    -- IF (_leaderID = NEW.userID) THEN
    --     SET teamApproved := 1;
    -- END IF;

    IF (userApproved = 0) THEN
        signal sqlstate '45000' set message_text = 'User is not approved';
    END IF;

    IF (teamApproved = 0 AND _leaderID != NEW.userID) THEN
        signal sqlstate '45000' set message_text = 'Team is not approved';
    END IF;
END;//

DELIMITER ;
