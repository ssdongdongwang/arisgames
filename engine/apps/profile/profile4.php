<?php
require_once('../../common.php');
page_header();


$_SESSION['profile_page'] = 4;

	echo '<h1>Task 4</h1>
		<p>Thank you for your telling response. So far you have the attributes of a: </p>';
	if (!isset($_REQUEST['feelings'])) echo '<h2>Vygot-99 personality</h2>'; 
	else {
		switch ($_REQUEST['feelings']) {
			case 1: 
				echo '<h2>Vygot-7 personality</h2>'; 
				break;
			case 2: 
				echo '<h2>Vygot-34 personality</h2>'; 
				break;
			case 3: 
				echo '<h2>Vygot-9 personality</h2>'; 
				break;
			case 4: 
				echo '<h2>Vygot-53 personality</h2>'; 
				break;
		}
	}
	echo '
		<br/><p>Go inside and talk with the bartender. Tell him you want to know who the "burger princess" is and give him a dollar bill. 
		He will give you the code-word to enter below.</p>
		<form id="form1" name="form1" method="post" action="profile5.php">
		  <p>Code Word: <input name="code" type="text"></p>
		  <p><input type="submit" name="button" id="button" value="Continue" /></p>
		</form>';

page_footer(); 
?>