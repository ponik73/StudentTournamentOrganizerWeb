<?php
    require '../Services.php';

    $serv = new TeamService();

    $res = $serv->getAll();
    
    $res = HandleServiceResult($serv, $res);

    $json = json_encode($res);

    echo $json;

    return TRUE;
?>
