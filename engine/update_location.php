<?php
include ('common.php');

if (isset($_REQUEST['latitude']) and isset($_REQUEST['longitude']) and isset($_SESSION['player_id'])) {
	
	echo '<h1>IM HERE</h1>';
	
	//Update Player latatide and longitude in players table
	$query = "UPDATE {$GLOBALS['DB_TABLE_PREFIX']}players 
			SET latitude = '{$_REQUEST['latitude']}', longitude = '{$_REQUEST['longitude']}' 
			WHERE player_id = '{$_SESSION['player_id']}'";
	mysql_query($query);
	
	//Update Session
	$_SESSION['latitude']=$_REQUEST['latitude'];
	$_SESSION['longitude']=$_REQUEST['longitude'];
	$_SESSION['last_location_timestamp']=time();
	
	//Check for a matching location and add event if specified
	$gps_error_factor = .0001 ;
		
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}locations 
		WHERE 
		latitude < " .  ($_REQUEST['latitude'] + $gps_error_factor) . " AND latitude > " .  ($_REQUEST['latitude'] - $gps_error_factor) . 
		" AND longitude < " . ($_REQUEST['longitude'] + $gps_error_factor) . " AND longitude > " .  ($_REQUEST['longitude'] - $gps_error_factor);  
	
	$result = mysql_query($query);

	if ($location = mysql_fetch_array($result)) {
		//The player is at a known location
		
		//Update player record in db
		$query = "UPDATE {$GLOBALS['DB_TABLE_PREFIX']}players 
			SET last_location_id = '{$location['location_id']}' 
			WHERE player_id = '{$_SESSION['player_id']}'";
		mysql_query($query);
		
		//Update the session
		$_SESSION['location_id'] = $location['location_id'];
		$_SESSION['location_name'] = $location['name'];

		//Give event to player if specified in location record
		if (isset($location['add_event_id'])) {
			$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id, event_id)
			VALUES ('{$_SESSION['player_id']}','{$location['add_event_id']}')"; 		
			mysql_query($query);
		}
	
	}
	else {
		//The player has left a known location
		//Update player record in db
		$query = "UPDATE {$GLOBALS['DB_TABLE_PREFIX']}players 
			SET last_location_id = '' 
			WHERE player_id = '{$_SESSION['player_id']}'";
		mysql_query($query);
		
		//Update the session
		unset($_SESSION['location_id']);
		unset($_SESSION['location_name']);

		//Give event to player if specified in location record
		if (isset($location['add_event_id'])) {
			$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id, event_id)
			VALUES ('{$_SESSION['player_id']}','{$location['add_event_id']}')"; 		
			mysql_query($query);
		}
	

	}
	


}

?>