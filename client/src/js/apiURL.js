/**
 * Project: Studentske turnaje
 * File: apiURL.js
 * Created: 6.11.2022
 * Author: Adam Dzurilla xdzuri00@stud.fit.vutbr.cz
 * 
 * Description: List of all api end points
 */

export default class apiURL {
    static users = {
        /**
         * @brief Returns list of users
         * 
         * @return {userID, username, created, isAdmin, isApproved}
         */
        getAll: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/getAll.php',

        /**
         * @brief Returns one user by id
         * 
         * @param id: Int
         * 
         * @return {userID, username, created, isAdmin, isApproved, matPlayed, matWon, matLost, tnmntPlayed, tnmntWon, tnmntLost}
         */
        getById: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/getById.php',

        /**
         * @brief Gets user id from session
         * 
         * @param SID: Int
         * 
         * @return {userID OR "no_user_logged_in"}
         */
        getCurrentUser: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/getCurrentUser.php',

        /**
         * @brief Gets participant name
         * 
         * @param idTP: Int
         * 
         * @return partId, partName, isUser
         */
        getParticipantInfo: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/getParticipantInfo.php',

        /**
         * @brief Checks if current user is in the tournament
         * 
         * @param SID: session_id -> OPTIONAL
         * @param tnmntID: Int
         * 
         * @return 1 or 0
         */
        isCurrentUserInTournament: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/isCurrentUserInTournament.php',

        /**
         * @brief Function checks if the session is set as admin and returns result
         * 
         * @param SID: sid -> OPTIONAL
         * 
         * @return 'true' or 'false'
         */
        isAdmin: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/isUserAdmin.php',

        /**
         * @brief Registeres player to the team, function validates if user and team are approved or if teamID and userID are not empty
         * 
         * @param teamID: Int
         * @param userID: Int
         */
        joinTeam: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/joinTeam.php',

        /**
         * @brief Registeres user to the tournament, function validates if tournament is for users, approves, attributes emptiness, occupancy etc.
         * 
         * @param tnmntID: Int
         * @param SID: idk - OPTIONAL
         */
        joinTournament: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/joinTournament.php',

        /**
         * @brief Validates username and password
         * 
         * @param username: String
         * @param pwd: String
         * 
         * @return SID (200) or 'false' (403)
         */
        login: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/login.php',

        /**
         * @brief Registeres new user and insert it into database
         * 
         * @param username: String
         * @param pwd: String
         * 
         * @return registeredUserItem
         */
        register: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/register.php',

        /**
         * @brief Removes user form db by id
         * 
         * @param userID: Int
         */
        remove: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/remove.php',

        /**
         * @brief Sets user as admin
         * 
         * @param SID: sid -> OPTIONAL
         * @param userID: Int
         */
        setAsAdmin: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/setAsAdmin.php',

        /**
         * @brief Updates user
         * 
         * @param userID: Int
         * @param username: String
         * @param oldPwd: String - optional
         * @param newPwd: String - optional
         */
        update: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/update.php',

        /**
         * @brief Starts PHP session (used at first page load)
         * 
         * @return ID of session
         */
        sessionStart: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/startSession.php',

        /**
         * @brief Logout user
         * 
         * @param SID: session id
         */
        logout: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/users/logout.php',
    }

    static teams = {
        /**
         * @brief Creates new team and insert it into database
         * 
         * @param leaderID: Int
         * @param teamName: String
         * @param logoUrl: String - OPTIONAL
         * 
         * @return createdTeamItem
         */
        create: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/create.php',

        /**
         * @brief Returns list of teams
         * 
         * @return {teamID, leaderID, teamName, created, isApproved}
         */
        getAll: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/getAll.php',

        /**
         * @brief Returns one team by id
         * 
         * @param id: Int
         * 
         * @return {teamID, leaderID, teamName, created, isApproved, membersCount, matPlayed, matWon, matLost, tnmntPlayed, tnmntWon, tnmntLost}
         */
        getById: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/getById.php',

        /**
         * @brief Returns all team members
         * 
         * @param teamID: Int
         * 
         * @return {userID, username}
         */
        getTeamPlayers: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/getTeamPlayers.php',

        /**
         * @brief Joins tournament as team, function validates if tournament is for teams, occupancy, attributes emptiness, approves etc.
         * 
         * @param tnmntID: Int
         * @param teamID: Int
         */
        joinTournament: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/joinTournament.php',

        /**
         * @brief Removes team form db by id
         * 
         * @param id: Int
         */
        remove: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/remove.php',

        /**
         * @brief Remove team member
         * 
         * @param userID: Int
         * @param teamID: Int
         */
        removeMember: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/removeMember.php',

        /**
         * @brief Updates teams
         * 
         * @param teamID: Int
         * @param leaderID: Int - OPTIONAL
         * @param teamName: String - OPTIONAL
         * @param logoUrl: String - OPTIONAL
         */
        update: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/teams/update.php',
    }

    static tournaments = {
        /**
         * @brief Approves tournament
         * 
         * @param id: Int
         */
        approve: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/approve.php',

        /**
         * @brief Approves tournament participant
         * 
         * @param participantID: Int
         */
        approveParticipant: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/approveParticipant.php',

        /**
         * @brief Creates new tournament and insert it into database
         * 
         * @param tnmntName: String
         * @param gameType: String
         * @param maxParticipants: unsigned Int
         * @param tnmntStart: Datetime -> format '2022-05-22 17:41:02'
         * @param isForTeams: 0 or 1
         * @param minPlayersPerGame: unsigned Int
         * 
         * @return createdTournamentItem
         */
        create: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/create.php',

        /**
         * @brief Generates bracket for tournament
         * 
         * Function creates random matches between participants and create empty matches for higher tournament rounds,
         * when tournament creator finishes the match, function FinishMatch will automatically push winner to the next round
         * 
         * @param tnmntID: Int
         * @param gameTimeInMinutes: Int
         */
        generateBracket: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/generateBracket.php',

        /**
         * @brief Generates bracket manually for tournament
         * 
         * Function gets first round from user and then generates other rounds, make control for first round etc.
         * 
         * @param tnmntID: Int
         * @param matches: Array of Matches, format as from getEmptyFirstRound
         * @param gameTimeInMinutes: Int
         */
        generateBracketManualy: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/generateBracketManualy.php',

        /**
         * @brief Returns list of tournaments
         * 
         * @return {tnmntID, tnmntName, gameType, maxParticipants, isForTeams, tnmntStart, isFinished, creatorID, minPlayersPerGame, isApproved, participantsCount}
         */
        getAll: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/getAll.php',

        /**
         * @brief Returns one tournament by id
         * 
         * @param tnmntID: Int
         * 
         * @return {tnmntID, tnmntName, gameType, maxParticipants, isForTeams, tnmntStart, isFinished, creatorID, creatorName, minPlayersPerGame, isApproved, participantsCount}
         */
        getById: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/getById.php',

        /**
         * @brief Returns empty matches, then user should fill them and send them back to generateBracketManualy.php
         * 
         * @param tnmntID: Int
         * 
         * @return List of empty matches -> array ([0] => array( 'partOneID' => '', 'partTwoID' => ''), ...)
         */
        getEmptyFirstRound: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/getEmptyFirstRound.php',

        /**
         * @brief Get tournaments by filter, if u do not want to filter some argument, do not pass it to api
         * e.g. If you want not started tournaments for CSGO game type pass to the function only alreadyStarted = 1 and gameType = 'CSGO'
         * 
         * @param tnmntName: String - OPTIONAL
         * @param gameType: String - OPTIONAL
         * @param expectedStartFrom: Datetime (e.g. 2022-02-16 17:31:45) - OPTIONAL
         * @param expectedStartUntil: Datetime (e.g. 2022-02-16 17:31:45) - OPTIONAL
         * @param couldJoin: 1 or 0 - OPTIONAL (This is negotion of isFull)
         * @param alreadyStarted: 1 or 0 - OPTIONAL
         * @param isFinished: 1 or 0 - OPTIONAL
         * @param isApproved: 1 or 0 - OPTIONAL
         * 
         * @return List of filtered tournaments
         */
        getFilteredTnmnt: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/getFilteredTnmnts.php',

        /**
         * @brief Gets list of participants of the tournament
         * 
         * @param tnmntID: Int
         * 
         * @return List of participants => [array('idTP' => xy, 'partName' => 'someParticipantInTournament')]
         */
        getTnmntParticipants: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/getTnmntParticipants.php',

        /**
         * @brief Removes tournament form db by id
         * 
         * @param id: Int
         */
        remove: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/remove.php',

        /**
         * @brief Removes participant
         * 
         * @param participantID: Int
         */
        removeParticipant: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/removeParticipant.php',

        /**
         * @brief Updates tournament
         * 
         * @param tnmntID: Int
         * @param tnmntName: String -> OPTIONAL
         * @param gameType: String -> OPTIONAL
         * @param maxParticipants: unsigned Int -> OPTIONAL
         * @param tnmntStart: Datetime -> OPTIONAL
         * @param isForTeams: 0 or 1 -> OPTIONAL
         * @param minPlayersPerGame: unsigned Int -> OPTIONAL
         */
        update: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/tournaments/update.php',
    }

    static matches = {
        /**
         * @brief Finishes match if it is possible and move winner to the next round
         * 
         * @param matchID: Int
         */
        finishMatch: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/matches/finishMatch.php',

        /**
         * @brief Get matches by filter, if u do not want to filter some argument, do not pass it to api
         * e.g. If you want finished user matches pass to the function only userID and isFinished = 1 attributes
         * 
         * @param userID: Int - OPTIONAL
         * @param teamID: Int - OPTIONAL
         * @param tnmntID: Int - OPTIONAL
         * @param isFinished: 0 or 1 - OPTIONAL
         * 
         * @return List of filtered matches
         */
        getFilteredMatches: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/matches/getFilteredMatches.php',

        /**
         * @brief Get match by id
         * 
         * @param matchID: Int
         * 
         * @return {matchID, matchStart, partOneID, partOneOGId, partOneScore, partTwoID, partTwoOGId, partTwoScore, tnmntRound, isFinished, tnmntID, isUserMatch}
         */
        getById: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/matches/getById.php',

        /**
         * @brief Removes all matches from tournament
         * 
         * @param tnmntID: Int
         */
        removeAllMatchesFromTnmnt: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/matches/removeAllMatchesFromTnmnt.php',

        /**
         * @brief Updates match
         * 
         * @param matchID: Int
         * @param partOneScore: Int - OPTIONAL
         * @param partTwoScore: Int - OPTIONAL
         * @param isFinished: 0 or 1 - OPTIONAL
         */
        update: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/matches/update.php',
        
        /**
         * @brief Get all matches from tournament
         * 
         * @param tnmntID: Int
         * 
         * @return {matchID, matchStart, partOneID, partOneScore, partTwoID, partTwoScore, tnmntRound, isFinished, tnmntID}
         */
        getTnmntMatches: 'https://www.stud.fit.vutbr.cz/~xdzuri00/api/matches/getMatchesByTnmnt.php',
    }
}
