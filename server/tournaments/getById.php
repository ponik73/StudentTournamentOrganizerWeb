<?php
    require '../Services.php';

    $data = array(
        'id' => ''
    );

    $data = SetChecksAttributesPost($data);

    $serv = new TournamentService();

    $res = $serv->getById($data);
    $res = HandleServiceResult($serv, $res, true);

    $res = $res[0];

    $json = json_encode($res);

    echo $json;

    return TRUE;
?>
