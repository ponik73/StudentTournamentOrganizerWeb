<?php
    session_start();

    if (isset($_SESSION['user']))
    {
        echo $_SESSION['user'];
        return TRUE;
    }
    else
    {
        echo 'no_user_logged_in';
        return FALSE;
    }
?>