<?php

session_start();

require "private/functions.php";
require "private/database.php";

$logFile = "private/spinely.log";

if ($_SERVER['REQUEST_METHOD'] == "POST") {
    //something was posted
    $username = $_POST['username'];
    $password = $_POST['password'];

    if (!empty($username) && !empty($password) && !is_numeric($username)) {

        // Database configuration
        $host = 'localhost';
        $dbname = 'userdata';
        $username = 'root';
        $password = '';

        // Establish a database connection
        try {
            $pdo = new PDO("mysql:host=$host;port=3307;dbname=$dbname", $username, $password);
        } catch(PDOException $e) {
            // If there is an error, handle it here
            echo "Connection failed: " . $e->getMessage();
        }

        $arr['username'] = $username;

        // read from database
        $query = "SELECT * FROM user WHERE username = :username LIMIT 1";
        $stm = $pdo->prepare($query);
        $stm->execute($arr);

        $data = $stm->fetch(PDO::FETCH_ASSOC);

        if ($data && password_verify($password, $data['password'])) {
            // Login successful, set session variable and redirect to index page
            success_log("Successful login");
            $_SESSION['username'] = $data['username'];
            header("Location: index.php");
            die;
        } else {
            // Login failed
            echo "<script>alert('Incorrect credentials.');</script>";   
            error_log("Wrong username or password!", 3, $logFile);
        }

    } else {
        echo "<script>alert('Incorrect credentials.');</script>";   
        error_log("Wrong username or password!", 3, $logFile);
    }
}

include "private/pages/login.html";
