<?php
/* Needs improvement on creating tables, display json, add calculations */

// connecting to database
$dbhost = "localhost";
$dbuser = "root";
$dbpass = "";
$dbname = "spinelytestV5"; // need change db name

$conn = new mysqli($dbhost, $dbuser, $dbpass);

$sql = "CREATE DATABASE IF NOT EXISTS $dbname";
if ($conn->query($sql) === FALSE) {
    echo "Error creating database: " . $conn->error;
}

$conn->select_db($dbname);

// creating tables

// read JSON payload 
$jsonPayload = file_get_contents('php://input');

// parsing JSON payload
$data = json_decode($jsonPayload, true);

// Process device_calibration data (example)
$calibrationData = isset($data['calibration']) ? $data['calibration'] : [];

foreach ($calibrationData as $calibration) {
    $type = isset($calibration['type']) ? $calibration['type'] : null;
    $value = isset($calibration['value']) ? filter_var($calibration['value'], FILTER_VALIDATE_INT) : null;

    if ($type !== null && $value !== null) {
        $stmt = $conn->prepare("INSERT INTO device_calibration ($type) VALUES (?)");
        $stmt->bind_param("i", $value);

        if ($stmt->execute()) {
            echo "Device calibration data inserted successfully.";
        } else {
            echo "Error: " . $stmt->error;
        }
        $stmt->close();
    }
}

$conn->close();

$response = array();

echo json_encode($response);

/* HTML below is for test only */
?>

<!DOCTYPE html>
<html>
<head>
    <title>Spinely (test page)</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script>
        function updateValues() {
            $.ajax({
                url: "spinelytest.php",
                type: "POST",
                contentType: "application/json",
                dataType: "json",
                data: JSON.stringify({
                    // replace with json content
                }),
                success: function(data) {
                    $("#value1").text(data.value1); // replace with html id and attribute from json

                },
                error: function(xhr, status, error) {
                    console.log("Error: " + error);
                }
            });
        }

        setInterval(updateValues, 1000); // change how many seconds
    </script>
</head>
<body>
    <h1>Arduino Data</h1>
    <p>Value 1: <span id="value1"><?php echo end($value1Array); ?></span></p>
</body>
</html>
