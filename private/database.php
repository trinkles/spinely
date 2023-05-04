<?php

$logFile = "private/spinely.log";
$dsn = 'mysql:host=localhost;port=3307;dbname=userdata';
$dbuser = "root";
$dbpass = "";

try {
    $con = new PDO($dsn, $dbuser, $dbpass);

    // exceptions for errors
    $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // create table if not exists
    $con->exec("CREATE TABLE IF NOT EXISTS users (
        user_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        fullname VARCHAR(255) NOT NULL,
        username VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL
    )");

} catch(PDOException $e){
    error_log("Connection failed: " . $e->getMessage(), 3, $logFile);
    echo "<script>alert('An error occurred. Please try again later.');</script>";
    exit;
}

