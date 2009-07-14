<?php

require_once('../../common.php');

page_header();

echo '<h1>Developer Tools</h1>';

echo "<h2><a href='player_map.php'>Show players' last locations on a map</a></h2>";
echo "<h2><a href='games.php'>Change Game/Server</a></h2>";
echo "<h2><a href='install_sql.php'>Install/Maintain SQL</a></h2>";
echo "<h2><a href='../../admin'>View Editor (Wanring, no way back)</a></h2>";
echo "<h2><a href='{$_SERVER['PHP_SELF']}?function=reset_events'>Reset my Events</a></h2>";
echo "<h2><a href='{$_SERVER['PHP_SELF']}?function=reset_items'>Reset my Items</a></h2>";
echo "<h2><a href='{$_SERVER['PHP_SELF']}?function=clear_session'>Clear the Session</a></h2>";

if (isset($_REQUEST['function'])) {

	if ($_REQUEST['function'] == 'reset_events') { 
		$query = "DELETE {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = '{$_SESSION['player_id']}'";
		mysql_query($query);
	}
	
	if ($_REQUEST['function'] == 'reset_items') { 
		$query = "DELETE {$GLOBALS['DB_TABLE_PREFIX']}player_items WHERE player_id = '{$_SESSION['player_id']}'";
		mysql_query($query);
	}
	
	if ($_REQUEST['function'] == 'clear_session') { 
		$player_id = $_SESSION['player_id'];
		session_destroy();
		$_SESSION['player_id'] = $player_id;
	}

}

page_footer();