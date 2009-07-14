<?php

require_once('../../common.php');
page_header();


//Set up a marker for each player in the players table
$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}players 
			WHERE latitude != ''
			AND longitude != ''";

$result = mysql_query($query);

//Player labels will collect the labels for use under the map
$player_labels = '';
 
//Map path will be the link to send to google for a custom static map
$map_path = 'http://maps.google.com/staticmap?maptype=mobile&size=320x200&key=' . $GLOBALS['GOOGLE_KEY'];
$map_path .= '&markers=';


$letters = array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z');
$i = 0;

while ($row = mysql_fetch_array($result)) {		  
	$lat = $row['latitude'];
	$long = $row['longitude'];
	$name = $row['user_name'];
	
	//Set color to green if updated within the last 5 minutes
	if ($row['timestamp'] < date ( 'm/d/Y h:i:s', time() - ( 60 * 5))) $color = 'green';
	else $color = 'red';
	
	//add a marker (google seems to forgive the trailing | if it exists)
	$map_path .= "$lat,$long,$color{$letters[$i]}|";
	
	//Add to player_labels string
	$ucletter = strtoupper($letters[$i]);
	$player_labels .= "<p>{$ucletter}. {$name}</p>";
	
	$i++;
}


// Cache the map_path for later updates
$map_path_cache = $map_path;

//Display the map
echo "<p><img id='mapImg' src = '$map_path'/></p>";


//Display the Player Labels
echo $player_labels;


page_footer();

?>