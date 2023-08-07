<?php
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Headers: *");

    function SetChecksAttributesPost($data)
    {
        foreach($data as $key => $value)
        {
            if (isset($_POST[$key]))
            {
                $value = trim($_POST[$key]);
            }
            else
            {
                echo "ERROR: Missing required property: ".$key.PHP_EOL;
                http_response_code(400);
                die();
            }

            if (empty($value) && $value != 0)
            {
                echo "ERROR: Empty attribute: ".$key.PHP_EOL;
                http_response_code(400);
                die();
            }

            $data[$key] = $value;
        }

        return $data;
    }

    function HandleServiceResult($serv, $res, $notEmptyArray = false)
    {
        if (gettype($res) == 'boolean')
        {
            if ($res == FALSE)
            {
                echo 'ERROR: '.$serv->getLastErrorMessage();
                http_response_code(400);
                die();
            }

            return $res;
        }
        else if (gettype($res) == 'array')
        {
            if ($notEmptyArray && empty($res))
            {
                echo 'ERROR: No record for passed attributes';
                http_response_code(400);
                die();
            }

            return $res;
        }
        else
        {
            echo 'ERROR: Unknown service result type';
            http_response_code(500);
            die();
        }
    }
?>
