<?php
    require '../Services.php';

    $data = array(
        'id' => ''
    );

    $data = SetChecksAttributesPost($data);

    $serv = new TeamService();

    $res = $serv->remove($data);
    $res = HandleServiceResult($serv, $res);

    echo 'OK';
    return TRUE;
?>
