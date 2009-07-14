<?php 
require_once('../../common.php');
page_header(); 

echo '<h1>Begin Psychological Profile</h1>
<p>In order to asses your compatibility with the New America Corporation\'s goals, please follow the following instructions. If at any time you feel uncomfortable, you may logout without reservation. No one will follow up or contact you again from NAC.</p>
<p>This assessment will take approximatly 30 minutes to 1 hour and will require you to travel to and around downtown Madison.</p>
<p>Your answers will be kept confidential within the NAC\'s HR department. By continuing with this activity you waive the right to hold  NAC responsible for any liability incurred during your time as a volunteer.</p>
<p>When you are ready to continue, click the link below. Answer honestly, there is no way to visit previous activities.</p>
<form id="form1" name="form1" method="post" action="profile1.php">
  <input type="submit" name="button" id="button" value="Continue with Assessment" />
</form>';


page_footer(); 

?>