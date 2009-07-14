<?php

require_once('common.php');

function print_form() {
	echo <<<FORM
	
	<form action='{$_SERVER['PHP_SELF']}' method='post'>
	<fieldset>
		<div class="fieldcontainer">
		<div class="row">
			<label>Username</label>
			<input type="text" name="user_name" />
		</div>
		<div class="row last">
			<label>Password</label>
			<input type="password" name="password" />
		</div>
		<input type="hidden" name="req" value="login" />
		<input type="hidden" name="location_detection" value="none" />
		</div>
		<div class="submit"><input type="submit" value="Login" /></div>
	</fieldset>
<!--	
	<form action = '$_SERVER[PHP_SELF]' method = 'post'>
	
	<table class='inputPanel' cellspacing='10'>
		<tr>
			<td>Username</td>
			<td><input type = 'text' size = '10' name = 'user_name'></td>
		</tr>
		<tr>
			<td>Password</td>
			<td><input type = 'password' size = '10' name = 'password'></td>
		</tr>
		<tr>
			<td>
				&nbsp;
			</td>
			<td><input type = 'hidden' name = 'req' value = 'login'>
			<input type = 'hidden' name = 'location_detection' value = 'none'>
			<input type = 'submit' value = 'login'></td
		</tr>
	</table>
-->
FORM;
}


if (!isset($_REQUEST['req'])) {
	
	page_header(null,TRUE);
	echo $GLOBALS['WELCOME_MESSAGE'];
	print_form();
	page_footer_no_nav();
}
else {
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}players WHERE user_name = '$_REQUEST[user_name]' and password = '$_REQUEST[password]'";
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	if ($row) {

		//Login successfull, load data
		$_SESSION['player_id'] = $row['player_id'];
		$_SESSION['user_name'] = $row['user_name'];
		$_SESSION['first_name'] = $row['first_name'];
		$_SESSION['last_name'] = $row['last_name'];
		$_SESSION['player_photo'] = $row['photo'];
		
		page_header();
		echo "<h1>Logging On</h2>";
		echo "<script type='text/javascript'>
				<!--
				window.location = '{$GLOBALS['WWW_ROOT']}/index.php'
				//-->
				</script>";
		page_footer();
	}
	else {
		//No matching Username and password
		page_header();
		echo "<h1>Access Denied</h1>";
		print_form();
		page_footer_no_nav();
	}
}
		
		
	
?>