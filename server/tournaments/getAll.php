<?php
    require '../Services.php';

    $serv = new TournamentService();

    $res = $serv->getAll();
    $res = HandleServiceResult($serv, $res);

    $json = json_encode($res);

    echo $json;

    return TRUE;
?>
