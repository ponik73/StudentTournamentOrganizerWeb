<?php
    require '../Services.php';

    session_start();

    $data = array(
        'username' => '',
        'pwd' => ''
    );

    $data = SetChecksAttributesPost($data);
    
    $serv = new UserService();

    $res = $serv->getUserForValidation($data);
    $res = HandleServiceResult($serv, $res, true);

    $user = $res[0];

    if (password_verify($data['pwd'], $user['pwd']))
    {
        echo 'true';
        $_SESSION['user'] = $user['userID'];
        $_SESSION['isAdmin'] = $user['isAdmin'] == 1;
        return TRUE;
    }
    else
    {
        echo 'false';
        http_response_code(403);
        return FALSE;
    }
?>
