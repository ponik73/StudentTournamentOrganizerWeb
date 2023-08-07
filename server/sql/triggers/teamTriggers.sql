\! echo "--------------------------------------------------------";
\! echo "Team triggers";

DELIMITER //

-- not approved user can not create team
DROP TRIGGER IF EXISTS notApprovedUserCannotCreateTeamTrg;
CREATE TRIGGER notApprovedUserCannotCreateTeamTrg
BEFORE INSERT ON Teams
FOR EACH ROW
BEGIN
    DECLARE _userApproved tinyint; 
    
    SET _userApproved := (SELECT isApproved FROM Users WHERE Users.userID = NEW.leaderID);

    IF (_userApproved = 0) THEN
        signal sqlstate '45000' set message_text = 'Not approved user can not create team';
    END IF;
END//

-- add leader as team player
DROP TRIGGER IF EXISTS addLeaderAsTeamPlayerTrg;
CREATE TRIGGER addLeaderAsTeamPlayerTrg
AFTER INSERT ON Teams
FOR EACH ROW
BEGIN
    CALL UserJoinsTeam(NEW.leaderID, NEW.teamID);
END//

DELIMITER ;
