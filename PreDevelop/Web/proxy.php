<?php

function getSslPage($url) {
    $ch = curl_init();

    $headers = array(
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        , "Accept-Charset: Windows-1251,utf-8;q=0.7,*;q=0.7"
        , "Accept-Language: ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3"
        , "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"
    );
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($ch, CURLOPT_HEADER, FALSE);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_REFERER, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    $result = curl_exec($ch);
    curl_close($ch);
    
    preg_match ('/^(.)*/', $_GET['url'], $match); 
    $base = $match[0];
    
    $result = str_replace('<head>', '<head>'.chr(13).chr(10).'<base href="'.$base.'" />', $result);
    return $result;
}

if (empty($_GET['url']))
    echo "";
else
    echo getSslPage($_GET['url']);
?>