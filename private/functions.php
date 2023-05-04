<?php

function check_login($con) {
    // Check if the user is logged in
    if(isset($_SESSION['username'])) {
        $user_ID = $_SESSION['username'];

        // prevent SQL injection
        $stmt = $con->prepare("SELECT * FROM users WHERE username = ?");
        $stmt->execute([$user_ID]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if($result) {
            // If the query was successful and a user was found, return the user data
            return $result;
        } else {
            // If no user was found, log the error
            error_log("check_login(): No user found with username $user_ID");
        }
    } else {
        // If the user is not logged in, log the error
        error_log("check_login(): User is not logged in");

        // Check if the user is already on the index page
        if(strpos($_SERVER['REQUEST_URI'], 'index.php') !== false) {
            // If the user is on the index page, do not redirect to the signup page
            return;
        } else {
            // If the user is not on the index page, redirect to the signup page
            header("Location: signup.php");
            die();
        }
    }
}



function success_log($message, $logFile = "private/success.log") {
    error_log("[SUCCESS]" . $message, 4, $logFile);
}
