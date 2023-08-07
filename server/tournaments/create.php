<?php
    require '../Services.php';

    $data = array(
        'tnmntName' => '',
        'gameType' => '',
        'maxParticipants' => '',
        'tnmntStart' => '',
        'creatorID' => '',
        'isForTeams' => '',
        'minPlayersPerGame' => ''
    );

    $data = SetChecksAttributesPost($data);
    
    $serv = new TournamentService();

    $res = $serv->create($data);
    $res = HandleServiceResult($serv, $res);
    
    echo 'OK';
    return TRUE;
?>
