<?php
    require '../Services.php';

    // if (!isset($_SESSION['isAdmin'])) return FALSE;

    // User is not admin
    // if ($_SESSION['isAdmin'] == '0') return FALSE;

    $data = array(
        'id' => ''
    );

    $data = SetChecksAttributesPost($data);

    $serv = new TournamentService();

    $res = $serv->approve($data);
    $res = HandleServiceResult($serv, $res);

    echo 'OK';
    return TRUE;
?>
