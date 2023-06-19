<?php

session_start();

require "private/functions.php";
require "private/database.php";

$logFile = "private/spinely.log";
$Error = "";

if($_SERVER['REQUEST_METHOD'] == "POST")
{
    //something was posted
    $fullname = addslashes($_POST['fullname']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $username = trim($_POST['username']);
    if(!preg_match("/^[a-zA-Z0-9]+$/",$username)){
        $Error = "Invalid username";
        echo "<script>alert('Please enter a valid username');</script>";
        error_log($Error, 3, $logFile);
    }
    $password = addslashes($_POST['password']);

    if($Error=="" && !empty($fullname) && !empty($email) && !empty($username) && !empty($password) && !is_numeric($username))
    {
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

        // Check if user already exists
        $query = "SELECT * FROM user WHERE username = :username OR email = :email";
        $stm = $pdo->prepare($query);
        $stm->bindParam(':username', $username);
        $stm->bindParam(':email', $email);
        $stm->execute();

        $result = $stm->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            // User already exists, display error message
            $Error = "User exists already";
            error_log($Error, 3, $logFile);

            $_SESSION['success_message'] = "The username or email address you entered is already registered. Please log in.";
            header("Location: login.php");
            die;
        } else {
            // Hash the password
            $hashed_password = password_hash($password, PASSWORD_DEFAULT);

            // Insert user data into the database
            $query = "INSERT INTO user (fullname, email, username, password) VALUES (:fullname, :email, :username, :password)";
            $stm = $pdo->prepare($query);
            $stm->bindParam(':fullname', $fullname);
            $stm->bindParam(':email', $email);
            $stm->bindParam(':username', $username);
            $stm->bindParam(':password', $hashed_password);
            $stm->execute();
            
            // New user
            $user_ID = $pdo->lastInsertId();

            // Redirect to login page
            $_SESSION['success_message'] = "Your account has been created successfully. Please log in.";
            success_log("Successful signup");
            header("Location: login.php");
            die;
        }
    } else {
        echo "<script>alert('An error occurred while creating your account. Please try again later.');</script>";
        error_log("Unexpected signup error", 3, $logFile);
    }
}

include "private/pages/signup.html";
