<?php
session_start();
include_once 'db_config.php';
include_once 'adminpanel.php';

$Admin = new adminpanel();
$Admin->run();
?>