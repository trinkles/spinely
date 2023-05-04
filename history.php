<?php
session_start();

require "private/functions.php";
require "private/database.php";

check_login($con);

include "private/pages/history.html";