<?php
    require '../Services.php';

    $data = array(
        'id' => ''
    );

    $data = SetChecksAttributesPost($data);

    $serv = new UserService();

    $res = $serv->getById($data);
    $res = HandleServiceResult($serv, $res, true);
    $res = $res[0];

    $teams = $serv->getUserTeams($data);
    $teams = HandleServiceResult($serv, $teams);
    $res['teams'] = $teams;

    $json = json_encode($res);
    echo $json;

    return TRUE;
?>
