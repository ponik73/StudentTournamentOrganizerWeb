--approved users
SELECT * FROM User WHERE isApproved = 1;

--not approved users
SELECT * FROM User WHERE isApproved = 0;

--approved teams
SELECT * FROM Team WHERE isApproved = 1;

--not approved teams
SELECT * FROM Team WHERE isApproved = 0;

--