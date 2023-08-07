<?php
    require '../Services.php';

    $data = array(
        'leaderID' => '',
        'teamName' => ''
    );

    $data = SetChecksAttributesPost($data);
    
    $serv = new TeamService();

    $res = $serv->create($data);
    $res = HandleServiceResult($serv, $res);

    echo 'OK';
    return TRUE;
?>
