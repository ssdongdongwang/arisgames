<?php
require_once('../../common.php');
page_header();


$_SESSION['profile_page'] = 5;

	
if ($_REQUEST['code'] ==  'correct') {
	echo '<h1>Assessment Complete</h1>
		<p>We believe you will be a great asset to the New America Corporation\'s work here in Madison.</p>
		<p>Your account has been put in the queue for creation and 
		a volunteer coordinator will be assigned to you by Friday August 22 at 5pm to give you your orientation and first assignment.</p>
		<p>We look forward to having you be a part of the NAC family.</p>';
	$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id,event_id)
			VALUES ('{$_SESSION['player_id']}','1')";
	mysql_query($query);
}
else {
	echo '<h1>Assessment Complete</h1>
		<p>This assessment has indicated that you may be a liability to the NAC.</p>
		<p>We will need further corespondance with you to determine if you will be suitable to be a part of our work.</p>
		<p>Send an appeal email to the recruiting officer explaining why you want to join the NAC and what you have to offer.</p>';
	$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id,event_id)
			VALUES ('{$_SESSION['player_id']}','2')";
	mysql_query($query);	
}	
	

page_footer(); 
?>