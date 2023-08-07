<?php
    require '../Services.php';

    function next_pow($number)
    {
        if (is_numeric($number))
            return pow(2,ceil(log($number,2)));

        return FALSE;
    }

    function create_round($matchServ, $tnmntRound, $participants, $roundStart, $tnmntId)
    {
        if ($participants == null)
        {
            $data = array(
                'matchStart' => $roundStart,
                'partOneId' => '0',
                'partTwoId' => '0',
                'tnmntRound' => $tnmntRound,
                'tnmntId' => $tnmntId
            );

            for ($i = 0; $i < $tnmntRound; $i++)
            {
                $res = $matchServ->create($data);
                $res = HandleServiceResult($matchServ, $res);
            }

            return;
        }
        
        $roundMatches = array_fill(0, $tnmntRound, array());
        $participant = array_pop($participants);
        $matchIndex = 0;
        while ($participant != null)
        {
            array_push($roundMatches[$matchIndex], $participant);
            $matchIndex++;

            if ($matchIndex >= $tnmntRound) $matchIndex = 0;

            $participant = array_pop($participants);
        }

        foreach ($roundMatches as $match)
        {
            $id1 = array_pop($match);
            $id1 = ($id1) ? $id1['idTP'] : '0';

            $id2 = array_pop($match);
            $id2 = ($id2) ? $id2['idTP'] : '0';

            $data = array(
                'matchStart' => $roundStart,
                'partOneId' => $id1,
                'partTwoId' => $id2,
                'tnmntRound' => $tnmntRound,
                'tnmntId' => $tnmntId
            );

            $res = $matchServ->create($data);
            $res = HandleServiceResult($matchServ, $res);
        }
    }

    $data = array(
        'tnmntID' => '',
        'gameTimeInMinutes' => ''
    );

    $data = SetChecksAttributesPost($data);

    $tnmntServ = new TournamentService();

    $matchServ = new MatchService();

    // Getting tournaments participants
    $tnmntIdData = array('tnmntID' => $data['tnmntID']);
    $tnmntParticipants = $tnmntServ->getTournamentParticipants($tnmntIdData);
    $tnmntParticipants = HandleServiceResult($tnmntServ, $tnmntParticipants);

    // Clearing matches in tournament
    $removeTnmntMatchesRes = $matchServ->removeAllTnmntMatches($tnmntIdData);
    $removeTnmntMatchesRes = HandleServiceResult($matchServ, $removeTnmntMatchesRes);

    // Getting tournament
    $idData = array('id' => $data['tnmntID']);
    $tnmnt = $tnmntServ->getById($idData);
    $tnmnt = HandleServiceResult($tnmntServ, $tnmnt, true);
    $tnmnt = $tnmnt[0];

    // Random bracket
    shuffle($tnmntParticipants);
    
    // Help variables for generating matches
    $gameTimeInMinutes = $data['gameTimeInMinutes'];
    $tnmntStart = $tnmnt['tnmntStart'];
    $currentDatetime = strtotime($tnmntStart);

    // Five minutes between first round and tournament start
    $currentDatetime = $currentDatetime+(60*5);

    $maxRound = next_pow(count($tnmntParticipants)) / 2;

    // Generating rounds
    for ($tnmntRound = $maxRound; $tnmntRound >= 1; $tnmntRound /= 2)
    {
        create_round($matchServ, $tnmntRound, $tnmntParticipants, date('Y-m-d H:i:s', $currentDatetime), $data['tnmntID']);
        $tnmntParticipants = null;
        $currentDatetime = $currentDatetime+(60*$gameTimeInMinutes);
    }

    // Data for setting finished matches in first round
    $finishMatchesData = array(
        'tnmntID' => $data['tnmntID'],
        'round' => $maxRound
    );

    $res = $matchServ->finishMatchesWithoutOpponentsInTournament($finishMatchesData);
    $res = HandleServiceResult($matchServ, $res);

    // Getting list of matches and printing it
    $res = $matchServ->getMatchesByTnmntId($tnmntIdData);
    $res = HandleServiceResult($matchServ, $res);

    $json = json_encode($res);

    echo $json;
?>
