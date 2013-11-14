<?php
session_start();
include_once 'db_config.php';
include_once 'bank.php';

$Bank = new bank();
$Bank->run();
?>