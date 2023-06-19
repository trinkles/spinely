<?php
// VARIABLES
$n = ""; // no. of proper posture checks
$h = ""; // hours
$sec = 10; // interval of posture checks
$c = $h * 3600; // hours in seconds

// store angle variables here
$cervicalAngle1 = "";
$cervicalAngle2 = "";
$thoracicAngle1 = "";
$thoracicAngle2 = "";
$lumbarAngle1 = "";
$lumbarAngle2 = "";

// no. of posture checks per day
$d1 = "";
$d2 = "";
$d3 = "";
$d4 = "";

// test hours per day (day 1: 8 hrs, day 2: 9 hrs, etc)
$h1 = "";
$h2 = "";
$h3 = "";
$h4 = "";
$hSum = $h1 + $h2 + $h3 + $h4; // sum of hours

$postureSesh = ($n * ($sec/$c))*100; // posture session formula
$postureSeshHour = ($n*$sec)/3600; // proper posture checks in hours

$cervicalAvg = ($cervicalAngle1 + $cervicalAngle2)/$n;
$thoracicAvg = ($thoracicAngle1 + $thoracicAngle2)/$n;
$lumbarAvg = ($lumbarAngle1 + $lumbarAngle2)/$n;

$y = (($d1 + $d2 + $d3 + $d4)/$hSum)*100; // posture progress %

?>
