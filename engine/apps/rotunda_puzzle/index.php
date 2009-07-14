<?php
require_once('../../common.php');

page_header();


//Check for correct response
if (isSet($_REQUEST['north']) and
	$_REQUEST['north'] == 'LaFallette' and
	$_REQUEST['west'] == 'Bell' and
	$_REQUEST['east'] == 'Constitution' and
	$_REQUEST['south'] == 'Veteran') {
	
	//Key to continue
	echo '<h1>Corect Response!</h1>';
	echo '<p>Agent,<br/>
			If you are reading this, then things must not be looking well for me. 
			This puzzle was designed to ensure that only an ARIS agent in Madison 2008 would be able to solve it and find me.
			I have more information, but will need to meet you face to face. Meet me at these coordinates.
			</p><p>
			Latitude : -89.4134  Longititude: 43.4563
			</p>';
	
	//Set an event ghetto style
	//Run a query to add the event to the user_events table
	
	$event_id = 904;
	
	$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id, event_id) 
		VALUES ('$_SESSION[player_id]','$event_id')";
	@mysql_query($query);
	if (mysql_error()) $return = 'error=true';
	
}
else { 
	$options = '<option></option>
				<option>LaFallette</option>
				<option>Bell</option>
				<option>Constitution</option>
				<option>Veteran</option>';
				
	$form = "<form action = '$_SERVER[PHP_SELF]' method = 'get'>
			<table width = '320px' background = 'rotunda_puzzle_background.png'>
			<tr height = '60px' align = 'center'><td>&nbsp;</td><td valign = 'middle' ><select name = 'north'> $options </select></td><td>&nbsp;</td></tr>
			<tr height = '60px' align = 'center'><td><select name = 'west' >$options </select></td><td><input type = 'submit' value = 'Artifacts Placed'/></td><td><select name = 'east'> $options </select></td></tr>
			<tr height = '55px' align = 'center'><td>&nbsp;</td><td><select name = 'south'> $options </select></td><td>&nbsp;</td></tr>
	
			</table>
			</form>";
			
	echo $form;		
}

page_footer();
?>