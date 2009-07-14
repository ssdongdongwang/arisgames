<?php
require_once('../../common.php');

page_header();


$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}scan 
			JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_events ON {$GLOBALS['DB_TABLE_PREFIX']}scan.require_event_id = {$GLOBALS['DB_TABLE_PREFIX']}player_events.event_id 
			WHERE 
			{$GLOBALS['DB_TABLE_PREFIX']}player_events.player_id = '$_SESSION[player_id]' 
			AND 
			{$GLOBALS['DB_TABLE_PREFIX']}scan.set_event_id NOT IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = $_SESSION[player_id])";	
//echo $query;		
$result = mysql_query($query);
$row = mysql_fetch_array($result);
if ($row) {
	//echo 'there was a row';
	$set_event_id = $row['set_event_id'];
	$title = $row['title'];
	$media = $GLOBALS['WWW_ROOT'] . '/media/' . $row['media'];
	
	echo "
	<table width='100%' border='0' background='scan_backgroup_graphic.gif'>
	  <tr>
		<td><img src = '$media' height = '110px'/></td>
		<td>";
			
			if (isset($_REQUEST['scan'])) {
				echo '<h1>Scan Successfull</h1><p>Physical data has been uploaded to base.</p>';
				$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id, event_id) 
							VALUES ('$_SESSION[player_id]','$set_event_id')";
				@mysql_query($query);
			}
			
			else  echo "
			<h1>Molecular Scanner</h1>
			<p>Item description: $title</p>
			<form action = '$_SERVER[PHP_SELF]' method = 'get'>
				<p><input type = 'submit' name = 'scan' value = 'Perform Scan'/></p>
			</form>";
			
	echo "</td>
	  </tr>
	</table>";
}
else {
	//echo 'there was not a row';
	echo "
	<table width='315' border='0' background='scan_backgroup_graphic.gif'>
	  <tr>
		<td width = '30%'>&nbsp;</td>
		<td>
			<h1>Molecular Scanner</h1>
			<p>Scanner Inactive. Base has not requested data.</p>
		</td>
	  </tr>
	</table>";
}



page_footer();

?>

