<?php
require_once('../../common.php');
page_header();
$_SESSION['profile_page'] = 1;

$query = "INSERT INTO {$GLOBALS['DB_TABLE_PREFIX']}player_applications (player_id,application_id)
			VALUES ('{$_SESSION['player_id']}','2')";

mysql_query($query);

echo '<h1>Task 1</h1>
<p>We have added a custom GPS application to your device. Use it to find and travel to Dotty Dumpling\'s Dowery.</p>
<p>When you have arrived, return to this application and click the button below to continue. Do NOT press the button below until you have reached your destination.</p>
<form id="form1" name="form1" method="post" action="profile2.php">
  <input type="submit" name="button" id="button" value="I am at Dotty\'s" />
</form>';

page_footer();
?>


