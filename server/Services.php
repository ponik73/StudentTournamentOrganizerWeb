<?php
    require "../IService.php";

    function connect_db(string $secretsFilePath)
    {
        $file = file_get_contents($secretsFilePath);
        $json_a = json_decode($file, true);

        $dsn = $json_a['ConnectionString']['DefaultConnection'];
        $username = $json_a['DbUsername'];
        $password = $json_a['DbPassword'];

        try {
            $pdo = new PDO($dsn, $username, $password);
        } catch (PDOException $e) {
            echo "Connection error: ".$e->getMessage();
            die();
        }

        return $pdo;
    }

    function executeStatement($serv, $stmt, $data, $expectedRes = true)
    {
        try
        {
            $stmtRes = $stmt->execute($data);
        }
        catch (Exception $e)
        {
            $serv->setLastError($stmt->errorInfo());
            return FALSE;
        }

        if (!$stmtRes)
        {
            $serv->setLastError($stmt->errorInfo());
            return FALSE;
        }

        if ($expectedRes)
        {
            $res = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $res;
        }
        else
        {
            return TRUE;
        }
    }

    class UserService implements IService
    {
        private $pdo;
        private $lastError;

        function __construct()
        {
            $this->pdo = connect_db("../secrets.json");
            $this->lastError = NULL;
        }

        function getLastErrorMessage()
        {
            if ($this->lastError == NULL)
                return '';
            else
                return $this->lastError[2];
        }

        function setLastError($error)
        {
            $this->lastError = $error;
        }

        function getAll()
        {
            $stmt = $this->pdo->prepare('CALL GetAllUsers()');

            return executeStatement($this, $stmt, null);
        }

        function getById($data)
        {
            $stmt = $this->pdo->prepare("CALL GetUserById(:id)");
            
            return executeStatement($this, $stmt, $data);
        }

        function getUserTeams($data)
        {
            $stmt = $this->pdo->prepare("CALL GetUsersTeams(:id)");

            return executeStatement($this, $stmt, $data);
        }

        function getLastUserId()
        {
            $stmt = $this->pdo->prepare('SELECT userID FROM Users ORDER BY userID DESC LIMIT 1');

            return executeStatement($this, $stmt, null);
        }

        function create($data)
        {
            $stmt = $this->pdo->prepare('CALL RegisterUser(:username, :pwd)');

            $res = executeStatement($this, $stmt, $data, false);

            if ($res)
            {
                $lastIdRes = $this->getLastUserId();

                $lastId = $lastIdRes[0]['userID'];

                $data['id'] = $lastId;
                return $data;
            }
            else
            {
                return FALSE;
            }
        }

        function remove($data)
        {
            $stmt = $this->pdo->prepare('CALL DeleteUser(:id)');

            return executeStatement($this, $stmt, $data, false);
        }

        function joinTournament($data)
        {
            $stmt = $this->pdo->prepare("CALL RegisterUserForTournament(:userID, :tnmntID)");

            return executeStatement($this, $stmt, $data, false);
        }

        function joinTeam($data)
        {
            $stmt = $this->pdo->prepare("CALL UserJoinsTeam(:userID, :teamID)");

            return executeStatement($this, $stmt, $data, false);
        }

        function getUserForValidation($data)
        {
            $stmt = $this->pdo->prepare("CALL GetUserForValidation(:username)");

            $newData = array(
                'username' => $data['username']
            );

            return executeStatement($this, $stmt, $newData);
        }

        function approve($data)
        {
            $stmt = $this->pdo->prepare("CALL ApproveUser(:id)");

            return executeStatement($this, $stmt, $data, false);
        }

        function setAsAdmin($data)
        {
            $stmt = $this->pdo->prepare("CALL SetUserAsAdmin(:id)");

            return executeStatement($this, $stmt, $data, false);
        }

        function isAdmin($data)
        {
            $stmt = $this->pdo->prepare("CALL IsUserAdmin(:userID)");

            $newData = array(
                'userID' => $data['userID']
            );

            return executeStatement($this, $stmt, $newData);
        }
    }

    class TeamService implements IService
    {
        private $pdo;
        private $lastError;

        function __construct()
        {
            $this->pdo = connect_db("../secrets.json");
            $this->lastError = NULL;
        }

        function getLastErrorMessage()
        {
            if ($this->lastError == NULL)
                return '';
            else
                return $this->lastError[2];
        }

        function setLastError($error)
        {
            $this->lastError = $error;
        }

        function getAll()
        {
            $stmt = $this->pdo->prepare("CALL GetAllTeams()");

            return executeStatement($this, $stmt, null);
        }

        function create($data)
        {
            $stmt = $this->pdo->prepare('CALL CreateTeam(:leaderID, :teamName)');

            $res = executeStatement($this, $stmt, $data, false);

            if ($res)
            {
                $data['id'] = $this->pdo->lastInsertId();
                return $data;
            }
            else
            {
                return FALSE;
            }
        }

        function getById($data)
        {
            $stmt = $this->pdo->prepare('CALL GetTeamById(:id)');

            return executeStatement($this, $stmt, $data);
        }

        function remove($data)
        {
            $stmt = $this->pdo->prepare('CALL DeleteTeam(:id)');
            
            return executeStatement($this, $stmt, $data, false);
        }

        function joinTournament($data)
        {
            $stmt = $this->pdo->prepare("call RegisterTeamForTournament(:teamID, :tnmntID)");

            $res = executeStatement($this, $stmt, $data, false);

            return ($res) ? $data : $res;
        }

        function approve($data)
        {
            $stmt = $this->pdo->prepare("CALL ApproveTeam(:id)");

            return executeStatement($this, $stmt, $data, false);
        }
    }

    class TournamentService implements IService
    {
        private $pdo;
        private $lastError;

        function __construct()
        {
            $this->pdo = connect_db("../secrets.json");
            $this->lastError = NULL;
        }

        function getLastErrorMessage()
        {
            if ($this->lastError == NULL)
                return '';
            else
                return $this->lastError[2];
        }

        function setLastError($error)
        {
            $this->lastError = $error;
        }

        function create($data)
        {
            $stmt = $this->pdo->prepare('CALL CreateTournament(:tnmntName, :gameType, 
            :maxParticipants, :isForTeams, :tnmntStart, :creatorID, :minPlayersPerGame)');

            $res = executeStatement($this, $stmt, $data, false);

            if ($res)
            {
                $data['id'] = $this->pdo->lastInsertId();
                return $data;
            }
            else
            {
                return FALSE;
            }
        }

        function getAll()
        {
            $stmt = $this->pdo->prepare('CALL GetAllTournaments()');

            return executeStatement($this, $stmt, null);
        }

        function getById($data)
        {
            $stmt = $this->pdo->prepare('CALL GetTournamentById(:id)');

            return executeStatement($this, $stmt, $data);
        }

        function getTournamentParticipants($data)
        {
            $stmt = $this->pdo->prepare('CALL GetTnmntsParticipants(:tnmntID)');

            return executeStatement($this, $stmt, $data);
        }

        function remove($data)
        {
            $stmt = $this->pdo->prepare('CALL DeleteTournament(:id)');

            return executeStatement($this, $stmt, $data, false);
        }

        function approve($data)
        {
            $stmt = $this->pdo->prepare("CALL ApproveTournament(:id)");

            return executeStatement($this, $stmt, $data, false);
        }
    }

    class MatchService implements IService
    {
        private $pdo;
        private $lastError;

        function __construct()
        {
            $this->pdo = connect_db("../secrets.json");
            $this->lastError = NULL;
        }

        function getLastErrorMessage()
        {
            if ($this->lastError == NULL)
                return '';
            else
                return $this->lastError[2];
        }

        function setLastError($error)
        {
            $this->lastError = $error;
        }

        function create($data)
        {
            $stmt = $this->pdo->prepare('CALL CreateMatch(:matchStart, :partOneId, :partTwoId, :tnmntRound, :tnmntId)');

            $res = executeStatement($this, $stmt, $data, false);

            if ($res)
            {
                $data['id'] = $this->pdo->lastInsertId();
                return $data;
            }
            else
            {
                return FALSE;
            }
        }

        function getAll()
        {
            $stmt = $this->pdo->prepare('CALL GetAllMatches()');

            return executeStatement($this, $stmt, null);
        }

        function getById($data)
        {
            $stmt = $this->pdo->prepare('CALL GetMatchByID(:id)');

            return executeStatement($this, $stmt, $data);
        }

        function getMatchesByTnmntId($data)
        {
            $stmt = $this->pdo->prepare('CALL GetMatchesByTnmntID(:tnmntID)');

            return executeStatement($this, $stmt, $data);
        }

        function remove($data)
        {
            $stmt = $this->pdo->prepare('CALL DeleteMatch(:id)');

            return executeStatement($this, $stmt, $data, false);
        }

        function removeAllTnmntMatches($data)
        {
            $stmt = $this->pdo->prepare('CALL DeleteMatchesFromTournament(:tnmntID)');

            return executeStatement($this, $stmt, $data, false);
        }

        function finishMatch($data)
        {
            $stmt = $this->pdo->prepare('CALL FinishMatch(:matchID)');

            return executeStatement($this, $stmt, $data, false);
        }

        function finishMatchesWithoutOpponentsInTournament($data)
        {
            $stmt = $this->pdo->prepare('CALL GetTournamentRoundMatchesWithIndex (:tnmntID, :round)');

            $res = executeStatement($this, $stmt, $data);

            foreach($res as $match)
            {
                if ($match['partTwoID'] == null || ($match['partOneScore'] != null && $match['partTwoScore'] != null))
                {
                    $stmtMat = $this->pdo->prepare('CALL FinishMatch(?)');
                    $resMat = executeStatement($this, $stmtMat, array($match['matchID']));
                }
            }

            return TRUE;
        }
    }
?>