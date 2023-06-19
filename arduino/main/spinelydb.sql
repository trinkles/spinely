-- can be imported to phpmyadmin
-- added more comments for context

-- create db
CREATE DATABASE IF NOT EXISTS SpinelyDB

-- switch db
USE SpinelyDB

-- Users Table
-- the very table to be referenced for main functions such as device calibration, monitoring, and sessions
CREATE TABLE IF NOT EXISTS users (
  userID INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(300) NOT NULL UNIQUE,
  pass TEXT NOT NULL
) 

-- Device Calibration Table
-- the basis for monitoring, it only has one row and should be replaced by using UPDATE query whenever user wishes to update calibration
CREATE TABLE IF NOT EXISTS device_calibration (
    calibrationID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    userID INT NOT NULL,
    cervical_angle_min FLOAT(10,2) NOT NULL,
    cervical_angle_max FLOAT(10,2) NOT NULL,
    cervical_angle_avg FLOAT(10,2) NOT NULL,
    thoracic_angle_min FLOAT(10,2) NOT NULL,
    thoracic_angle_max FLOAT(10,2) NOT NULL,
    thoracic_angle_avg FLOAT(10,2) NOT NULL,
    lumbar_angle_min FLOAT(10,2) NOT NULL,
    lumbar_angle_max FLOAT(10,2) NOT NULL,
    lumbar_angle_avg FLOAT(10,2) NOT NULL,
    left_midAxLine_angle_min FLOAT(10,2) NOT NULL,
    left_midAxLine_angle_max FLOAT(10,2) NOT NULL,
    left_midAxLine_angle_avg FLOAT(10,2) NOT NULL,
    right_midAxLine_angle_min FLOAT(10,2) NOT NULL,
    right_midAxLine_angle_max FLOAT(10,2) NOT NULL,
    right_midAxLine_angle_avg FLOAT(10,2) NOT NULL,
    calibration_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES users(userID)
) 

-- Sessions Table
-- session is a day, it will handle the data for the day
CREATE TABLE IF NOT EXISTS sessions (
  sessionID int(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  userID INT NOT NULL,
  percent_proper float(10,2) NOT NULL,
  time_start date NOT NULL,
  time_end date NOT NULL,
  FOREIGN KEY (userID) REFERENCES users(userID)
)

-- Monitoring Table
-- the table with most relations to other tables. it provides multiple sets of data for a session, it relates with the user info, and its data is checked with calibration
CREATE TABLE IF NOT EXISTS monitoring (
  monitoringID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  sessionID INT NOT NULL,
  calibrationID INT NOT NULL,
  userID INT NOT NULL,
  cervical FLOAT(10,2) NOT NULL,
  thoracic FLOAT(10,2) NOT NULL,
  lumbar FLOAT(10,2) NOT NULL,
  leftmidAx FLOAT(10,2) NOT NULL,
  rightmidAx FLOAT(10,2) NOT NULL,
  postureStatus ENUM('proper', 'improper') NOT NULL DEFAULT 'proper',
  monitoring_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sessionID) REFERENCES sessions(sessionID),
  FOREIGN KEY (calibrationID) REFERENCES device_calibration(calibrationID),
  FOREIGN KEY (userID) REFERENCES users(userID)
)	

-- Sessions Angle Table
-- angles per session, uses data from monitoring
CREATE TABLE IF NOT EXISTS session_angle_avgs (
  angleavID INT(11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
  sessionID INT NOT NULL,
  monitoringID INT NOT NULL,
  cervical_avg_session FLOAT(10,2) NOT NULL,
  thoracic_avg_session FLOAT(10,2) NOT NULL,
  lumbar_avg_session FLOAT(10,2) NOT NULL,
  leftMidAx_avg_session FLOAT(10,2) NOT NULL,
  rightMidAx_avg_session FLOAT(10,2) NOT NULL,
  FOREIGN KEY (monitoringID) REFERENCES monitoring(monitoringID),
  FOREIGN KEY (sessionID) REFERENCES sessions(sessionID)
)

-- Progress Report Table
-- removed 'improper' columns
CREATE TABLE IF NOT EXISTS progress_report (
  progressID INT(11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
  sessionID INT NOT NULL,
  results_proper FLOAT(10,2) NOT NULL,
  progress_proper FLOAT(10,2) NOT NULL,
  date_time datetime NOT NULL,
  FOREIGN KEY (sessionID) REFERENCES sessions(sessionID),
)
