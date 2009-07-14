<?php

ini_set('display_errors','1');

$DB_HOST='localhost';
$DB_USER='arisuser';
$DB_PASSWORD='arispwd';
$DB_SCHEMA='aris';
$DB_TABLE_PREFIX = 'dev_'; 

$WWW_ROOT='http://atsosxdev.doit.wisc.edu/aris/dev';
$FILE_ROOT='/Groups/web/aris/dev';
$IMAGE_DIR = $FILE_ROOT. '/media/'; 


require_once($FILE_ROOT . '/includes/session.inc.php');
require_once($FILE_ROOT . '/includes/db.inc.php');
require_once($FILE_ROOT . '/includes/utils.inc.php');
require_once($FILE_ROOT . '/theme/theme.inc.php');

$TITLE = 'ARIS Demo';

$WELCOME_MESSAGE = '<h1>Login to the ARIS development site</h1>
			<p>This site is best viewed on iPhone but may work on other browsers with javascript support</p>
			<p>Email djgagnon@wisc.edu with any problems or feedback</p>';
			
$SPLASH_SCREEN = "<h1>Welcome Back Agent</h1>
			<p align = 'center'><img width = '280' src = './media/madison.jpg'/></p>
			<p>To restore contact with us, use your CHAT application below</p>";		
			
$GOOGLE_KEY = 'ABQIAAAA_CE3Nypcp6bilTqyCg-N2hQsvlSBtAWfm4N2P3iTGfWOp-UrmRQgXVI4kOqbJnZJDYqrPvf7deonfw';	 //This is needed for each URL. Goto http://code.google.com/apis/maps/signup.html to register	

?>
