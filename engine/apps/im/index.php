<?php

require_once('../../common.php');

function node_not_found_error($node_id, $prev_node_id) {
	echo '<h1>Sorry. Node not found!</h1>';
	echo "<p>Looks like the programmers forgot to create a node or made a bad link from the correct answer to a question.
	Tell them that you were coming to node $node_id from node $prev_node_id when you had the problem.</p>";
	page_footer();
	die();
}


page_header('im.css');

//Check if we already clicked on a conversation and should be displaying a node
if (isset($_REQUEST['node_id']) or isset($_REQUEST['question_node_id'])) {
	
	
	//Display the node
	$display_conversation = TRUE; //Conversations are only displayed if no node options exist. This switch keeps track of whether or not the conversations should be displayed.


	//Check if we are coming back with a answer string
	if (isSet($_REQUEST['answer_string']) and isSet($_REQUEST['question_node_id']) ) {
		
		//Load the node
		$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}nodes WHERE node_id = '$_REQUEST[question_node_id]'";
		$result = mysql_query($query);
		$row = mysql_fetch_array($result);
		
		//Check the row exists
		if (!$row) node_not_found_error($_REQUEST['question_node_id'], $_SESSION['last_node']); 
		
		//Is it the correct answer?
		if (strtolower(trim($_REQUEST['answer_string'])) == strtolower($row['require_answer_string'])) {
			//we have a correct answer, set the next row to load
			$_REQUEST['node_id'] = $row['require_answer_correct_node_id'];
		}
		else {
			//we have the wrong answer, set the next node to load
			$_REQUEST['node_id'] = $row['required_condition_not_met_node_id'];
		}
		
	}
	
	
	//Load the Node
	if (isSet($_REQUEST['node_id'])) $query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}nodes WHERE node_id = '$_REQUEST[node_id]'";
	else if (isSet($_SESSION['last_node'])) $query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}nodes WHERE node_id = '$_SESSION[last_node]'";
	$result = mysql_query($query);
	$row = mysql_fetch_array($result);
	
	
	if ($row) {
		$messages = '';
		
		//Check for a required item
		
		if ($row['require_item_id'] > 0) {
			//Check if the player owns this item
			$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}player_items WHERE player_id = '$_SESSION[player_id]' and item_id = '$row[require_item_id]'";
			$result = mysql_query($query);
			
			if (!mysql_fetch_array($result)) {
				//Item not found, load the required_item_not_found_node_id
				$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}nodes WHERE node_id = $row[required_condition_not_met_node_id]";
				$result = mysql_query($query);
				$row = mysql_fetch_array($result);
			}
			
			if (!$row) node_not_found_error($row['required_condition_not_met_node_id'],$_SESSION['last_node']);
		}
		
	
		//Check for a new item
		if ($row['add_item_id']) {	
			$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}items WHERE item_id = $row[add_item_id]";
			$result = mysql_query($query);
			$new_item = mysql_fetch_array($result);
			
			if ($new_item) {
				$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_items (player_id, item_id) VALUES ($_SESSION[player_id], $row[add_item_id])";
				$result = mysql_query($query);
				$messages .= "<p><font color = 'red'>Item Recieved: $new_item[name]</font></p>";
			}
			else $messages .=  "<p> <font color = 'red'>Add Item Error. Item $row[add_item_id] was added from node $row[node_id] but doesn't exist.</font></p>";
		}
		
		
		//Check for a remove item
		if ($row['remove_item_id']) {	
			$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}items WHERE item_id = $row[remove_item_id]";
			$result = mysql_query($query);
			$new_item = mysql_fetch_array($result);
			
			if ($new_item) {
				$query = "DELETE FORM {$GLOBALS['DB_TABLE_PREFIX']}player_items WHERE player_id = $_SESSION[player_id] and item_id = $row[remove_item_id])";
				$result = mysql_query($query);
				$messages .=  "<p><font color = 'red'>Item Removed: $new_item[name]</font></p>";
			}
			else $messages .=  "<p><font color = 'red'>Remove Item Error. Item $row[recieve_item_id] was removed from node $row[node_id] but doesn't exist.</font></p>";
		}
		
		echo '<hr/>';
		
			
		
		//Check for an added event_id
		if ($row['add_event_id'] > 0) {
			//Add the event from the node
			$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_events (player_id, event_id) 
					VALUES ('$_SESSION[player_id]','$row[add_event_id]')";
			@mysql_query($query);
		}
		
		
		//Check for a remove event_id
		//Need to do this
		
	
		//Check for a removed item_id
		//Need to do this
	
	
		//Check if this is a question node
		if ($row['require_answer_string']) $display_conversation = FALSE;
		
		
		//Display the node information
		define('IM', true);
		echo "<h1>Chat with Base</h1>";
		
		/*
		$_SESSION['chat_history'] is an array that holds the text and media displayed not only from a node's text, but also the response the user selected.
		
		For each element in the $history array, two sub-indexes exist, 'media' and 'text'
		
		*/
		
		//Caculate the size of the history 
		if (isset($_SESSION['chat_history'])) $history_size = sizeof($_SESSION['chat_history']);
		else $history_size = 0;
		
		//If the user doesn't have a history and the crrent node information was not the last node on the stack,
		//push onto the stack and display the history
		if (
			(isset($_SESSION['chat_history']) and $_SESSION['chat_history'][$history_size-1]['text'] != $row['text']) or
			!isset($_SESSION['chat_history'])
			) {
			
			
			//put the last option on the stack
			if (isset($_GET['prev_opt_text'])) {
				$_SESSION['chat_history'][$history_size]['text'] = $_GET['prev_opt_text']; 
				$_SESSION['chat_history'][$history_size]['media'] = 'player.jpg'; 
				$history_size++;
			}
			
			//put the node text on the stack
			$_SESSION['chat_history'][$history_size]['text'] = $row['text']; 
			$_SESSION['chat_history'][$history_size]['media'] = $row['media']; 
			
			//Display the history
			echo '<table>';
			
			
			for ($i = 0; $i<$history_size; $i++) {	
				echo '<tr><td>';
				$media = $_SESSION['chat_history'][$i]['media'];
				echo "<img class = 'chat_icon' src = '$WWW_ROOT/media/{$media}'/>";
				echo urldecode($_SESSION['chat_history'][$i]['text']);
				echo '</td></tr>';
			}
			
		}
		
		
		//Display the current node text
		echo '<tr><td>';
		echo "<img class = 'chat_icon' src = '$WWW_ROOT/media/$row[media]'/>";
		echo "<p>$row[text]</p>";
		echo '</td></tr>';
		echo '</table>';
		
		
		print ('<br/>');
		
		// Display the node options
		if ($row['opt1_text'] or $row['opt2_text'] or $row['opt3_text']) {
			print ('<p>Your Response:</p>');
			$corrected = urlencode($row['opt1_text']);
			if ($row['opt1_text']) echo "<p><a href = '{$_SERVER['PHP_SELF']}?node_id=$row[opt1_node_id]&prev_opt_text={$corrected}'>$row[opt1_text]</a></p>";
			$corrected = urlencode($row['opt2_text']);
			if ($row['opt2_text']) echo "<p><a href = '{$_SERVER['PHP_SELF']}?node_id=$row[opt2_node_id]&prev_opt_text={$corrected}'>$row[opt2_text]</a></p>";
			$corrected = urlencode($row['opt3_text']);
			if ($row['opt3_text']) echo "<p><a href = '{$_SERVER['PHP_SELF']}?node_id=$row[opt3_node_id]&prev_opt_text={$corrected}'>$row[opt3_text]</a></p>";
		}
		
		
		//Display the possible npc_conversations
		else if ($display_conversation == TRUE) {
		
		
			$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}npc_conversations 
			WHERE  
			(require_event_id IS NULL OR require_event_id IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = $_SESSION[player_id])) 
			and 
			(require_location_id IS NULL OR require_location_id IN (SELECT last_location_id FROM {$GLOBALS['DB_TABLE_PREFIX']}players WHERE player_id = $_SESSION[player_id])) 
			and
			({$GLOBALS['DB_TABLE_PREFIX']}npc_conversations.remove_if_event_id IS NULL 
			OR {$GLOBALS['DB_TABLE_PREFIX']}npc_conversations.remove_if_event_id 
			NOT IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = 	$_SESSION[player_id]))
			and
			npc_id = $_SESSION[current_npc_id]
			ORDER BY node_id DESC";
				
			$result = mysql_query($query);
			echo mysql_error();
		
			while ($npc_node = mysql_fetch_array($result)){
				echo "<p><a href = '{$_SERVER['PHP_SELF']}?node_id=$npc_node[node_id]'>$npc_node[text]</a></p>";
			}
			
		}
		
		echo '<hr id="bottom" style="clear: left;" />';
		
		echo '
		<script type="application/x-javascript">
			window.onload = function() {setTimeout(function(){window.scrollTo(bottom);}, 100);}
		</script>';

	
		//Display the question from
		if ($row['require_answer_string'])
			echo "<p><form action = '$_SERVER[PHP_SELF]' method = 'get'>
					<table style='width: 100%;'><tr>
						<td><input type = 'text' size = '35' name = 'answer_string'></td>
						<td><input type = 'submit' value = 'Send'/></td>
					</tr></table>
					<input type = 'hidden' name = 'question_node_id' value = '$_REQUEST[node_id]'/>  
					</form>
					</p>";
		
	
		
		//Update the session
		if (isset($_REQUEST['node_id'])) $_SESSION['last_node'] = $_REQUEST['node_id'];
		
		//Display any messages
		echo $messages;
		
		
	}
	
	else node_not_found_error($row['node_id'],$_SESSION['last_node']);
	
	

}


//Check if we clicked on an NPC and should list possible conversations
else if (isset($_REQUEST['npc_id'])) {
	
	//Display the conversations to kick things off
	$_SESSION['current_npc_id'] = $_REQUEST['npc_id'];
	
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}npcs WHERE npc_id = $_REQUEST[npc_id]";
	$result = mysql_query($query);
	$npc = mysql_fetch_array($result);
	
	echo "<h1>$npc[name]</h1><hr/><br/><p>Say:</p>";

	//Find and display any npc_conversations that should be shown here
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}npc_conversations 
	WHERE  
	(require_event_id IS NULL OR require_event_id IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = $_SESSION[player_id])) 
	and 
	(require_location_id IS NULL OR require_location_id IN (SELECT last_location_id FROM {$GLOBALS['DB_TABLE_PREFIX']}players WHERE player_id = $_SESSION[player_id])) 
	and
	({$GLOBALS['DB_TABLE_PREFIX']}npc_conversations.remove_if_event_id IS NULL OR {$GLOBALS['DB_TABLE_PREFIX']}npc_conversations.remove_if_event_id 
	NOT IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = 	$_SESSION[player_id]))
	and
	npc_id = $_REQUEST[npc_id]
	ORDER BY node_id DESC";

	$result = mysql_query($query);

	while ($npc_node = mysql_fetch_array($result)){
		echo "<p><a class='npc_option' href = '{$_SERVER['PHP_SELF']}?node_id=$npc_node[node_id]'>$npc_node[text]</a></p>";
	}	
	
}



//We must be starting from scratch, Display the contact List
else {	

	//Display title
	echo "<h1>Contact List</h1>";
			
	//Clear out the last conversation history
	unset($_SESSION['chat_history']);
		
	
	//Load and display contact list (NPCs at location 0)
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}npcs 
			WHERE location_id = '0' and (require_event_id IS NULL or require_event_id 
			IN (SELECT event_id FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events WHERE player_id = $_SESSION[player_id]))";
	
	$result = mysql_query($query);
		
	echo '<table width = "100%">';
	
	while ($npc = mysql_fetch_array($result)) {
		$image = (!is_null($npc['media']) && $npc['media'] != '') 
			? "<img src='$WWW_ROOT/media/{$npc['media']}' class='list' />"
			: '';
	
		echo <<<CONTACT
<tr>
	<td>
		<h2><a href='{$_SERVER['PHP_SELF']}?npc_id={$npc['npc_id']}'>$npc[name]</a></h2>
		<p>$npc[description]</p>
	</td>
	<td align = 'right'>$image</td>
</tr>

CONTACT;
	}
	echo '</table>';
}



page_footer();

?>