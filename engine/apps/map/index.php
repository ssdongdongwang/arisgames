<?php

require_once('../../common.php');
unset($_SESSION['current_npc_id']);

page_header();


if (isset($_REQUEST['location_id'])) {

	//The player has been here and clicked on a map link
		
	//Update the player record
	$query = "UPDATE {$GLOBALS['DB_TABLE_PREFIX']}players SET last_location_id = $_REQUEST[location_id] WHERE player_id = $_SESSION[player_id]";
	mysql_query($query);
	
	
	//Update the session
	$_SESSION['last_location_id'] = $_REQUEST['location_id'];
	
	//Load the loaction data and display the name
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}locations WHERE location_id = {$_REQUEST['location_id']}";
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	echo "<h1>$row[name]</h1>";
	
	//Display the media for the location
	if ($row['media']) echo "<p align = 'center'><img src = '{$WWW_ROOT}/media/$row[media]' height = '200px'/></p>";
	
	//Show nearby npcs
	echo "<h2>Nearby People/ Objects in Augmented Reality:</h2>";
	$layout = 'f2f';
	echo '<hr/>';
	
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}npcs WHERE location_id = '$_REQUEST[location_id]' and 
	(require_event_id IS NULL or require_event_id IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events 
	WHERE player_id = $_SESSION[player_id]))";
	
	$result = mysql_query($query);
	
	echo '<table width = "100%">';
	while ($row = mysql_fetch_array($result)) {
	
		echo "<tr>
				<td><a href = 'ar.php?npc_id=$row[npc_id]'>$row[name]</a><p>$row[description]</p></td>
				<td align = 'right'><img src = '$WWW_ROOT/media/$row[media]' height = '30px' width = '40px'/></td>
			</tr>";
	}
	echo '</table>';
}


else {
	//Display a map, we didn't come here with a location to display

	$player_at_location = false; //a switch to use if a player is at a defined locaiton
	
	
	//Set up a marker for each location in the locations table
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}locations 
				LEFT OUTER JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_events 
				ON 
				{$GLOBALS['DB_TABLE_PREFIX']}locations.require_event_id = {$GLOBALS['DB_TABLE_PREFIX']}player_events.event_id
				WHERE latitude != '' 
				AND longitude != ''
				AND (require_event_id IS NULL OR player_id = $_SESSION[player_id])
				AND
				({$GLOBALS['DB_TABLE_PREFIX']}locations.remove_if_event_id IS NULL 
					OR {$GLOBALS['DB_TABLE_PREFIX']}locations.remove_if_event_id NOT IN 
					(SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = 	$_SESSION[player_id])
				)";
	
				
	$result = mysql_query($query);
	
	 
	$map_path = 'http://maps.google.com/staticmap?maptype=mobile&size=320x200&key=' . $GLOBALS['GOOGLE_KEY'];
	$map_path .= '&markers=';
	
	$colors = array('green', 'purple', 'yellow', 'blue', 'gray', 'orange', 'red', 'white', 'black', 'brown');
	$letters = array('a','b','c','d','e','f','g','h','i','j','k');
	$i = 0;
	
	while ($row = mysql_fetch_array($result)) {		  
		$lat = $row['latitude'];
		$long = $row['longitude'];
		$name = $row['name'];
		$lid = $row['location_id'];
		//add a marker (google seems to forgive the trailing | if it exists)
		$map_path .= "$lat,$long,{$colors[$i]}{$letters[$i]}|";
		$i++;
	}
	
	
	// Cache the map_path for later updates
	$map_path_cache = $map_path;
	
	//Set up a player icon
	if (isset($_SESSION['latitude']) and isset($_SESSION['longitude']) ) {
	
		//add a marker
		$map_path .= "{$_SESSION['latitude']},{$_SESSION['longitude']},yellow";
				
	}
	
	//Display current location
	if (isset($_SESSION['location_id'])) echo "<h1><a href = '{$_SERVER['PHP_SELF']}?location_id={$_SESSION['location_id']}'>Current Location: {$_SESSION['location_name']} </a></h1>";
	
	
	//Display the map
	echo "<p><img id='mapImg' src = '$map_path'/></p>";
	echo "<script type='text/javascript'>var map_cache = \"$map_path_cache\";</script>";

	
	//Display the Locatons as links under the map using the same letters as in the map
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}locations 
				LEFT OUTER JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_events 
				ON {$GLOBALS['DB_TABLE_PREFIX']}locations.require_event_id = {$GLOBALS['DB_TABLE_PREFIX']}player_events.event_id
				WHERE 
				(require_event_id IS NULL OR player_id = $_SESSION[player_id])
				and
				({$GLOBALS['DB_TABLE_PREFIX']}locations.remove_if_event_id IS NULL 
					OR 
					{$GLOBALS['DB_TABLE_PREFIX']}locations.remove_if_event_id NOT IN 
					(SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = 	$_SESSION[player_id])
				)";
				
	$locations_dataset = mysql_query($query);
	
	$i = 0;
	
	while( $location = mysql_fetch_array($locations_dataset) ) {					
		//echo "<p><a href = '{$_SERVER['PHP_SELF']}?location_id=$location[location_id]'>{$letters[$i]}. {$location['name']}</a></p>";
		$letter = strtoupper($letters[$i]);
		echo "<p>{$letter}. {$location['name']}</p>";
		$i++;
		
	}

}


page_footer();

?>