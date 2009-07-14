<?php
	$HTTP_GET_VARS = $_GET;
	$HTTP_POST_VARS = $_POST;
	session_name('aris_editor');
	session_start();
	include_once('config.inc.php');
	include_once('theme.inc.php');

	//Connect to the db
	$db = mysql_connect($opts['hn'], $opts['un'], $opts['pw']);
	echo mysql_error();
	mysql_select_db($opts['db'], $db);
	
	//Check that a user is logged on
	if (!isset($_SESSION['user_name'])) {
		print_header('Login to ARIS');
		include_once('login.inc.php');
		die();
	}
	


?>