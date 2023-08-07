use xdzuri00;

CREATE TABLE if not exists Users
(
    userID int not null auto_increment,
    username varchar(50) not null unique,
    pwd varchar(255) not null,
    created timestamp default CURRENT_TIMESTAMP,
    isAdmin tinyint not null default 0,
    isApproved tinyint not null default 0,
    primary key(userID)
);

CREATE TABLE if not exists Teams
(
    teamID int not null auto_increment,
    leaderID int not null,
    teamName varchar(50) not null unique,
    created timestamp default CURRENT_TIMESTAMP,
    isApproved tinyint not null default 0,
    primary key(teamID),
    foreign key(leaderID) references Users(userID) on delete cascade
);

CREATE TABLE if not exists TeamPlayers
(
    id int not null auto_increment,
    teamID int not null,
    userID int not null,
    primary key(id),
    foreign key(teamID) references Teams(teamID) on delete cascade,
    foreign key(userID) references Users(userID) on delete cascade
);

CREATE TABLE if not exists Tournaments
(
    tnmntID int not null auto_increment,
    tnmntName varchar(50) not null,
    gameType varchar(50) not null,
    maxParticipants smallint not null,
    isForTeams tinyint not null default 0, 
    tnmntStart datetime not null,
    isFinished tinyint not null default 0,
    creatorID int not null,
    minPlayersPerGame smallint not null default 1,
    isApproved tinyint not null default 0,
    primary key(tnmntID),
    foreign key(creatorID) references Users(userID) on delete cascade
);

CREATE TABLE if not exists Participants
(
    idTP int not null auto_increment,
    tnmntID int not null,
    userID int,
    teamID int,
    placement smallint,
    primary key(idTP),
    foreign key(tnmntID) references Tournaments(tnmntID) on delete cascade,
    foreign key(userID) references Users(userID) on delete cascade,
    foreign key(teamID) references Teams(teamID) on delete cascade,
    CONSTRAINT unique_tnmnt_user UNIQUE (tnmntID, userID),
    CONSTRAINT unique_tnmnt_team UNIQUE (tnmntID, teamID)
);

CREATE TABLE if not exists Matches
(
    matchID int not null auto_increment,
    matchStart datetime not null,
    partOneID int,
    partOneScore int,
    partTwoID int,
    partTwoScore int,
    tnmntRound smallint not null,
    isFinished tinyint not null default 0,
    tnmntID int not null,
    primary key(matchID),
    foreign key(partOneID) references Participants(idTP),
    foreign key(partTwoID) references Participants(idTP),
    foreign key(tnmntID) references Tournaments(tnmntID) on delete cascade
);
