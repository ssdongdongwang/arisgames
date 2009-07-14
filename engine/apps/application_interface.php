<?php
require_once('../common.php');

$return = 'error=false';

if (isset($_REQUEST['add_event_id'])){
	//Run a query to add the event to the user_events table
	$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id, event_id) 
		VALUES ('$_SESSION[player_id]','$_REQUEST[add_event_id]')";
	@mysql_query($query);
	if (mysql_error()) $return = 'error=true';
}

if (isset($_REQUEST['remove_event_id'])){
	//Run a query to add the event to the user_events table
	$query = "DELETE FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE event_id = '$_REQUEST[add_event_id]'";
	@mysql_query($query);
	if (mysql_error()) $return = 'error=true';
}

echo $return;


?>