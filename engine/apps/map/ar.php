<?php

require_once('../../common.php');

function node_not_found_error($node_id, $prev_node_id) {
	echo '<h1>Sorry. Node not found!</h1>';
	echo "<p>Looks like the programmers forgot to create a node or made a bad link from the correct answer to a question.
	Tell them that you were coming to node $node_id from node $prev_node_id when you had the problem.</p>";
	page_footer();
	die();
}


page_header();

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
		
		
		
		//Display the Node
		echo "<h1>$row[title]</h1>";
	
		echo "<p align = 'center' ><img src = './media/$row[media]'/></p>";
		
				
		echo "<p align = 'center'>$row[text]</p>";
		
		echo "<br/>Say:<hr/>";
		
		// Display the options
		if ($row['opt1_text'] or $row['opt2_text'] or $row['opt3_text']) {
			if ($row['opt1_text']) echo "<p><a href = 'node.php?node=$row[opt1_node_id]&layout=f2f'>$row[opt1_text]</a></p><br/>";
			if ($row['opt2_text']) echo "<p><a href = 'node.php?node=$row[opt2_node_id]&layout=f2f'>$row[opt2_text]</a></p><br/>";
			if ($row['opt3_text']) echo "<p><a href = 'node.php?node=$row[opt3_node_id]&layout=f2f'>$row[opt3_text]</a></p><br/>";
		}
			
		//Display the possible npc_conversations
		else {
		
		
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
				echo "<p><a class='npc_option' href = 'node.php?node=$npc_node[node_id]&layout=f2f'>$npc_node[text]</a></p>";
			}
			
		}
	
		//Display the question form
		if ($row['require_answer_string'])
			echo "<p><form action = '$_SERVER[PHP_SELF]' method = 'get'>
					<table><tr>
						<td><input type = 'text' size = '15' name = 'answer_string'></td>
						<td><input type = 'submit' value = 'Say'/></td>
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
	
	echo "<h1>Chat with $npc[name]</h1><hr/><br/><p>Say:</p>";

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



//We must have gotten here accidentally
else  echo 'ERROR: No Node or NPC specified. Tell the programmers you encoutered this message';



page_footer();

?>