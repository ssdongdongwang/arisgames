<?php
require_once('common.php');
page_header();
echo "<h1>{$GLOBALS['TITLE']}</h1>";
echo '<h2>You have been Logged Out.</h2>';
echo '<br/>';
echo '<h2><a href = "index.php">Return to Login Screen</a></h2>';
session_destroy();
page_footer_no_nav();

?>