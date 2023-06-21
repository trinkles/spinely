-- can be imported to phpmyadmin

-- create db
CREATE DATABASE IF NOT EXISTS SpinelyDB

-- switch db
USE SpinelyDB

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  userID INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(300) NOT NULL UNIQUE,
  pass TEXT NOT NULL
); 

-- Device Calibration Table
CREATE TABLE IF NOT EXISTS device_calibration (
    calibrationID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    userID INT NOT NULL,
    cervical_angle_min INT(5) NOT NULL,
    cervical_angle_max INT(5) NOT NULL,
    cervical_angle_avg INT(5) NOT NULL,
    thoracic_angle_min INT(5) NOT NULL,
    thoracic_angle_max INT(5) NOT NULL,
    thoracic_angle_avg INT(5) NOT NULL,
    lumbar_angle_min INT(5) NOT NULL,
    lumbar_angle_max INT(5) NOT NULL,
    lumbar_angle_avg INT(5) NOT NULL,
    left_midAxLine_angle_min INT(5) NOT NULL,
    left_midAxLine_angle_max INT(5) NOT NULL,
    left_midAxLine_angle_avg INT(5) NOT NULL,
    right_midAxLine_angle_min INT(5) NOT NULL,
    right_midAxLine_angle_max INT(5) NOT NULL,
    right_midAxLine_angle_avg INT(5) NOT NULL,
    calibration_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES users(userID)
);

-- Sessions Table
CREATE TABLE IF NOT EXISTS sessions (
  sessionID int(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  userID INT NOT NULL,
  percent_proper float(10,2) NOT NULL,
  time_start time NOT NULL,
  time_end time NOT NULL,
  FOREIGN KEY (userID) REFERENCES users(userID)
);

-- Progress Report Table
CREATE TABLE IF NOT EXISTS progress_report (
  progressID INT(11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
  sessionID INT NOT NULL,
  results_proper FLOAT(10,2) NOT NULL,
  progress_proper FLOAT(10,2) NOT NULL,
  date_time datetime NOT NULL,
  FOREIGN KEY (sessionID) REFERENCES sessions(sessionID)
);

-- Monitoring Table
CREATE TABLE IF NOT EXISTS monitoring (
  monitoringID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  sessionID INT NOT NULL,
  cervical INT(5) NOT NULL,
  thoracic INT(5) NOT NULL,
  lumbar INT(5) NOT NULL,
  leftmidAx INT(5) NOT NULL,
  rightmidAx INT(5) NOT NULL,
  postureStatus ENUM('proper', 'improper') NOT NULL DEFAULT 'proper',
  monitoring_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sessionID) REFERENCES sessions(sessionID)
);
