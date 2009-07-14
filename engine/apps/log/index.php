<?php

require_once('../../common.php');

page_header();


echo '<h1>To Do</h1>';


//Display the current tasks
echo '<h2>Active</h2>';

$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}log
			LEFT OUTER JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_events 
				ON {$GLOBALS['DB_TABLE_PREFIX']}log.require_event_id = {$GLOBALS['DB_TABLE_PREFIX']}player_events.event_id
			WHERE 
				(require_event_id IS NULL OR player_id = $_SESSION[player_id]) 
			AND 
				({$GLOBALS['DB_TABLE_PREFIX']}log.complete_if_event_id IS NULL 
			OR {$GLOBALS['DB_TABLE_PREFIX']}log.complete_if_event_id 
				NOT IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events 
					WHERE player_id = $_SESSION[player_id]))";
$result = mysql_query($query);

echo '<table>';
while ($row = mysql_fetch_array($result)) {
	// This is important for some reason:
	// <!-- <a class='quest_list' href='$WWW_ROOT/node.php?node={$row['start_node_id']}'> -->
	echo <<<TASK
	<tr>
		<td class='taskimg'><img class='quest_list' src='{$GLOBALS['WWW_ROOT']}/media/{$row['media']}'></td>
		<td>
			<h3 class='task'>{$row['name']}</h3>
			<p class='task'>{$row['description']}</p>
		</td>
	</tr>
TASK;

}
echo '</table>';





//Display the completed tasks
echo "<hr/>";
echo '<h2>Completed</h2>';

$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}log
			WHERE {$GLOBALS['DB_TABLE_PREFIX']}log.complete_if_event_id 
				IN 
					(SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events 
						WHERE player_id = $_SESSION[player_id])";
			
$result = mysql_query($query);

echo '<table>';

while ($row = mysql_fetch_array($result)) {
	echo <<<TASK
	
	<tr>
		<td class="taskimg"><img class="quest_list" src="{$GLOBALS['WWW_ROOT']}/media/{$row['media']}"</td>
		<td>
			<h3 class="task">{$row['name']}</h3>
			<p class="task">{$row['text_when_complete']}</p>
		</td>
	</tr>
	
TASK;
}

echo '</table>';


page_footer();

?>