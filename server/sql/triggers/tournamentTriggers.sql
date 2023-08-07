\! echo "--------------------------------------------------------";
\! echo "Tournament triggers";

DELIMITER //

-- Checks tournament approvness
DROP TRIGGER IF EXISTS checksTnmntCreatorApprovnessTrg;
CREATE TRIGGER checksTnmntCreatorApprovnessTrg
BEFORE INSERT ON Tournaments
FOR EACH ROW
BEGIN
    DECLARE userApprovness TINYINT;

    SET userApprovness := (SELECT isApproved FROM Users WHERE Users.userID = NEW.creatorID);

    IF (userApprovness = 0) THEN
        signal sqlstate '45000' set message_text = 'User which is creating the tournament is not approved';
    END IF;
END//

DELIMITER ;
