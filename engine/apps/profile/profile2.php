<?php
require_once('../../common.php');
page_header();


//Check if they actually made it
$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}players
	WHERE player_id = '$_SESSION[player_id]'";
$result = mysql_query($query);
$player = mysql_fetch_array($result);

$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}locations
	WHERE location_id = '1'";
$result = mysql_query($query);
$location = mysql_fetch_array($result);

$gps_error_factor = .0005;

if ($player['latitude'] <= $location['latitude'] + $gps_error_factor and $player['latitude'] >= $location['latitude'] - $gps_error_factor 
	and
	$player['longitude'] <= $location['longitude'] + $gps_error_factor and $player['longitude'] >= $location['longitude'] - $gps_error_factor ) {
	
	$_SESSION['profile_page'] = 2;
	
	$query = "DELETE FROM {$GLOBALS['DB_TABLE_PREFIX']}player_applications WHERE player_id = '{$_SESSION['player_id']}' and application_id=  '2' ";
	mysql_query($query);

	echo '<h1>Task 2</h1>
		<p>Enter three items you noticed during your trip to Dotty\'s</p>
		<p>Do not think too long, simply type in the first things that come to mind.		
		</p>
		<form id="form1" name="form1" method="post" action="profile3.php">
		  <p>Thing 1: <input type = "text" name = "item1"></p>
		  <p>Thing 2: <input type = "text" name = "item2"></p>
		  <p>Thing 3: <input type = "text" name = "item3"></p>
		  <input type="submit" name="button" id="button" value="Submit" />
		</form>';

} 
else {
	echo '<h1>Issue Recorded</h1>
			<p>You have not gone to the location we asked. This discrepancy was recored in your profile</p>
			<p>Click the button below when you have reached Dotty\'s<p>
			<form id="form1" name="form1" method="post" action="profile2.php">
		  	<input type="submit" name="button" id="button" value="I am now at Dotty\'s" />
			</form>';
			
}
page_footer(); 
?>