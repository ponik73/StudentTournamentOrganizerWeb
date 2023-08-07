# Procedures

## Match procedures

- CreateMatch (matchStart, partOneID, partTwoID, tnmntRound, tnmntID);
- GetAllMatches();
- GetMatchByID (matchID);
- GetMatchesByTnmntID (tnmntID);
- DeleteMatch (matchID);
- DeleteMatchesFromTournament (tnmntID);
- FinishMatch (matchID);
- GetTournamentRoundMatchesWithIndex (tnmntID, tnmntRound);
- InsertParticipantToTheMatchOnIndexInTnmntRound (tnmntID, tnmntRound, matchIndex, participantID);
- AddParticipantToMatch (participantID, matchID);

## Team procedures

- ApproveTeam (teamID);
- CreateTeam (leaderID, teamName);
- DeleteTeam (teamID);
- GetAllTeams();
- GetTeamById (teamID);
- RegisterTeamForTournament (teamID, tnmntID);

## Tournament procedures

- ApproveTournament (tnmntID);
- CreateTournament (tnmntName, gameType, maxParticipants, isForTeams, tnmntStart, creatorID, minPlayersPerGame);
- DeleteTournament (tnmntID);
- GetAllTournaments();
- GetTournamentById (id);
- GetTnmntsParticipants (tnmntID);

## User procedures

- ApproveUser (userID);
- DeleteUser (userID);
- GetAllUsers();
- GetUserById (userID);
- GetUsersTeams (userID);
- GetUserForValidation (username);
- IsUserAdmin (userID);
- RegisterUser (username, pwd);
- RegisterUserForTournament (userID, tnmntID);
- UserJoinsTeam (userID, teamID);
- SetUserAsAdmin (userID);
