<?php
    require '../Services.php';

    $serv = new UserService();

    $res = $serv->getAll();

    $res = HandleServiceResult($serv, $res);

    $json = json_encode($res);

    echo $json;

    return TRUE;
?>
