<?php
    require '../Services.php';

    function errorIfStrContainsWhiteSpaces($stringForCheck)
    {
        if (str_contains($stringForCheck, ' ') 
        || str_contains($stringForCheck, '\t') 
        || str_contains($stringForCheck, chr(10)) 
        || str_contains($stringForCheck, chr(13)))
        {
            echo 'Username and password can not contain spaces, new lines and tabulators';
            http_response_code(400);
            die();
        }
    }

    session_start();

    $data = array(
        'username' => '',
        'pwd' => ''
    );

    $data = SetChecksAttributesPost($data);

    errorIfStrContainsWhiteSpaces($data['username']);
    errorIfStrContainsWhiteSpaces($data['pwd']);
    
    $data['pwd'] = password_hash($data['pwd'], PASSWORD_DEFAULT);
    
    $serv = new UserService();

    $res = $serv->create($data);
    $res = HandleServiceResult($serv, $res);
    
    echo $res['id'];
    $_SESSION['user'] = $res['id'];
    $_SESSION['isAdmin'] = false;
    return TRUE;
?>
