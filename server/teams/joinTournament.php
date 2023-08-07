<?php
    require '../Services.php';

    $data = array(
        'tnmntID' => '',
        'teamID' => ''
    );

    $data = SetChecksAttributesPost($data);
    
    $serv = new TeamService();

    $res = $serv->joinTournament($data);
    $res = HandleServiceResult($serv, $res);
    
    echo 'OK';
    return TRUE;
?>
