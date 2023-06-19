-- can be imported to phpmyadmin

-- create db
CREATE DATABASE IF NOT EXISTS SpinelyDB

-- switch db
USE SpinelyDB

-- create tables

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  userID INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  username VARCHAR(100) NOT NULL UNIQUE KEY ,
  email VARCHAR(300) NOT NULL UNIQUE KEY,
  pass TEXT NOT NULL,
) 

-- Device Calibration Table
CREATE TABLE IF NOT EXISTS device_calibration (
    calibrationID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    userID INT(11) UNIQUE KEY NOT NULL,
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
    calibration_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) 

-- Monitoring Table
CREATE TABLE IF NOT EXISTS monitoring (
  monitoringID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  sessionID INT(11) UNIQUE KEY NOT NULL,
  userID INT(11) UNIQUE KEY NOT NULL,
  cervical FLOAT(10,2) NOT NULL,
  thoracic FLOAT(10,2) NOT NULL,
  lumbar FLOAT(10,2) NOT NULL,
  leftmidAx FLOAT(10,2) NOT NULL,
  rightmidAx FLOAT(10,2) NOT NULL,
  postureStatus ENUM('proper', 'improper') NOT NULL DEFAULT 'proper',
  monitoring_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)	

-- Sessions Table
CREATE TABLE IF NOT EXISTS sessions (
  sessionID int(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  userID int(11) UNIQUE KEY NOT NULL,
  percent_proper float(10,0) NOT NULL,
  time_start date NOT NULL,
  time_end date NOT NULL,
)

-- Sessions Angle Table
CREATE TABLE IF NOT EXISTS session_angle_avgs (
    angleavID INT(11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    sessionID INT(11) UNIQUE KEY NOT NULL,
    cervical_avg_session FLOAT(10,2) NOT NULL,
    thoracic_avg_session FLOAT(10,2) NOT NULL,
    lumbar_avg_session FLOAT(10,2) NOT NULL,
    leftMidAx_avg_session FLOAT(10,2) NOT NULL,
    rightMidAx_avg_session FLOAT(10,2) NOT NULL,
)

-- Progress Report Table
CREATE TABLE IF NOT EXISTS progress_report (
  progressID INT(11) PRIMARY KEY AUTO_INCREMENT NOT NULL,
  sessionID INT(11) UNIQUE KEY NOT NULL,
  results_proper FLOAT(10,0) NOT NULL,
  results_improper FLOAT(10,0) NOT NULL,
  progress_proper FLOAT(10,0) NOT NULL,
  progress_improper FLOAT(10,0) NOT NULL,
  date_time datetime NOT NULL,
)

-- OPTIONAL/LEGACY: spine_range table
CREATE TABLE IF NOT EXISTS spine_range (
    spineID INT(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
    userID INT(11) UNIQUE KEY NOT NULL,
    cervical_angle_min FLOAT(10,2) NOT NULL,
    cervical_angle_max FLOAT(10,2) NOT NULL,
    cervical_angle_avg FLOAT(10,2) NOT NULL,
    thoracic_angle_min FLOAT(10,2) NOT NULL,
    thoracic_angle_max FLOAT(10,2) NOT NULL,
    thoracic_angle_avg FLOAT(10,2) NOT NULL,
    lumbar_angle_min FLOAT(10,2) NOT NULL,
    lumbar_angle_max FLOAT(10,2) NOT NULL,
    lumbar_angle_avg FLOAT(10,2) NOT NULL,
)
