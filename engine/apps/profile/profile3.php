<?php
require_once('../../common.php');
page_header();


$_SESSION['profile_page'] = 3;
	echo '<h1>Task 3</h1>
		<p>Your input  and travel time was recorded and will help us to understand your psychological profile.</p>
		<p>Which phrase below best describes your reaction to the above fact?</p>
		<form id="form1" name="form1" method="post" action="profile4.php">
		  <p><input name="feelings" type="radio" value="1"> My answers and travel time do not describe anything about me</p>
		  <p><input name="feelings" type="radio" value="2"> The NAC cares about me as an individual</p>
		  <p><input name="feelings" type="radio" value="3"> I wonder how the data will be used</p>
		  <p><input name="feelings" type="radio" value="4"> I am curious to learn more about NAC</p>
		  <p><input type="submit" name="button" id="button" value="Continue" /></p>
		</form>';

page_footer(); 
?>