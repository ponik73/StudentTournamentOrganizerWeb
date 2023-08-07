<?php
    require '../Services.php';

    $data = array(
        'teamID' => '',
        'userID' => ''
    );

    $data = SetChecksAttributesPost($data);
    
    $serv = new UserService();

    $res = $serv->joinTeam($data);
    $res = HandleServiceResult($serv, $data);
    
    echo 'OK';
    return TRUE;
?>
