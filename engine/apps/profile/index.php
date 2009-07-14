<?php
require_once('../../common.php');


$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}player_events 
			WHERE player_id = '{$_SESSION['player_id']}'";
$result = mysql_query($query);
if ($event = mysql_fetch_array($result)) {
	//There must be an event, so they have done the profile already
	page_header();
	if ($event['event_id'] == '1') echo '<h1>Wait to be  contacted by the Volenteer Coordinator</h1>
				<p>We have your email and will contacting you shortly</p>';
	if ($event['event_id'] == '2') echo '<h1>Contact the recruiter to appeal</h1>
				<p>Your profile indicates that you may be a liability for NAC. Email the recruiter with your appeal.</p>';
	page_footer();
	die();
}


if (isset($_SESSION['profile_page'])) { 
	switch ($_SESSION['profile_page']) {
		case 1:
			include ('profile1.php');
			break;
		case 2:
			include ('profile2.php');
			break;
		case 3:
			include ('profile3.php');
			break;
		case 4:
			include ('profile4.php');
			break;
		case 5:
			include ('profile5.php');
			break;	
	}
}
else include ('intro.php');

?>