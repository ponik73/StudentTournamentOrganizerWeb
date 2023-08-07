<?php
    require '../Services.php';

    $data = array(
        'tnmntID' => '',
        // 'userID' => $_SESSION['username']
        'userID' => ''
    );

    $data = SetChecksAttributesPost($data);
    
    $serv = new UserService();

    $res = $serv->joinTournament($data);
    $res = HandleServiceResult($serv, $res);
    
    echo 'OK';
    return TRUE;
?>
