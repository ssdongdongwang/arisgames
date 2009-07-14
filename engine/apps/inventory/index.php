<?php
require_once('../../common.php');
unset($_SESSION['current_npc_id']);

page_header();

/*
//NAC File Browser
echo <<<PREAMBLE


	<div class="toolbar">
		<h1 id="pageTitle"></h1>
		<a id="backButton" class="button" href="#"></a>
	</div>
	
	<ul id="home" title="Files" selected="true">
PREAMBLE;

$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}items 
	JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_items 
		ON {$GLOBALS['DB_TABLE_PREFIX']}items.item_id = {$GLOBALS['DB_TABLE_PREFIX']}player_items.item_id 
	WHERE {$GLOBALS['DB_TABLE_PREFIX']}player_items.player_id = '$_SESSION[player_id]'";
	
$result = mysql_query($query);
$items = array();

while ($row = mysql_fetch_assoc($result)) {
	array_push($items, array($row['item_id'], $row['name'], $row['description'], $row['media']));
	echo <<<ITEM
		<li><a href="#item{$row['item_id']}">{$row['name']}</a></li>

ITEM;
}

echo "</ul>\n";

// Create the info pages
foreach ($items as $item) {
	echo <<<ITEM
	<div id="item{$item[0]}" title="{$item[1]}">
		<img class="file" src="{$GLOBALS['WWW_ROOT']}/media/{$item[3]}" />
		<p class="file">{$item[2]}</p>
	</div>
	
ITEM;
}
*/

if (!isset($_REQUEST['item_id'])) {
	echo '<h1>NAC File Browser</h1>';
	
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}items JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_items ON {$GLOBALS['DB_TABLE_PREFIX']}items.item_id = {$GLOBALS['DB_TABLE_PREFIX']}player_items.item_id WHERE {$GLOBALS['DB_TABLE_PREFIX']}player_items.player_id = '$_SESSION[player_id]'";
				
	$result = mysql_query($query);
	
	echo '<table cellspacing = "5px">';
	
	if (mysql_num_rows($result) == 0) echo "<tr><td>No files found.</td></tr>";
	
	while ($row = mysql_fetch_array($result)) {
		echo '<tr>';
		echo "<td><a href = '$_SERVER[PHP_SELF]?item_id=$row[item_id]'><img width = '75px' height = '100px' src='$WWW_ROOT/media/$row[media]'/></a></td>
		<td><h2><a href = '$_SERVER[PHP_SELF]?item_id=$row[item_id]'>$row[name]</a></h2><p>$row[description]</p></td>";
		echo '</tr>';
	}
	
	echo '</table>';

}

else {
	//We are comming back to display an item full screen
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}items WHERE item_id = '$_REQUEST[item_id]'";		
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	echo "<h1>$row[name]</h1>";
	echo "<p align = 'center'><img src = '{$WWW_ROOT}/media/{$row['media']}'/></p>";
	echo "<p align = 'center'>$row[description]</p>";
	echo "<p align = 'center'><a href = $_SERVER[PHP_SELF]/>Back to File Browser</a></p>";
	
}

page_footer();


?>

