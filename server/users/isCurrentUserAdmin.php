<?php
    require '../Services.php';

    session_start();

    if (isset($_SESSION['user']))
    {
        $currentUserID = $_SESSION['user'];

        $userServ = new UserService();

        $res = $userServ->isAdmin(array('userID' => $currentUserID));
        $res = HandleServiceResult($userServ, $res, true);

        
        $isAdmin = $res[0]['isAdmin'];

        if ($isAdmin == '1')
        {
            echo 'true';
            return TRUE;
        }
    }

    echo 'false';
    return FALSE;
?>