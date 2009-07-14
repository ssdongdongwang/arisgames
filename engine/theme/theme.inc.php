<?php

/*
Output standard html tags and load the common css. If a param is passed, additional css can be loaded as well
*/
function page_header($additional_layout=null, $login_page=null) {

	
	//Set up basic HTML and CSS header information
	echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<meta name="viewport" content="width=device-width">
		<title>'. $GLOBALS['TITLE'] . '</title>
		<style type="text/css" media="all">
		@import url('. $GLOBALS['WWW_ROOT'] . '/theme/common.css);
	';
	
	
	if ($additional_layout != null) echo "@import url($additional_layout);";
	
	echo "</style>";
	
	//Set up the location update js. If the client is the ARIS native app, this gets called when location is updated and then calls the iframe page
	echo "
		
		<script type='text/javascript'>
		var number = 1;

		function update_location(lat, long) {

			/*
 			frames['utils_frame'].location.href = 
 				'{$GLOBALS['WWW_ROOT']}/update_location.php?latitude=' 
 				+ lat + '&longitude=' + long;
        	number++;
        	*/
        	
        	var request = new XMLHttpRequest();
        	request.open('GET', '{$GLOBALS['WWW_ROOT']}/update_location.php?latitude=' + 	
        		lat + '&longitude=' + long, true);        		
        	request.setRequestHeader('Content-Type', 'application/x-javascript;');        	
        	request.onreadystatechange = function() {
        		if (request.readyState == 4 && request.status == 200) {
        			update_map(lat, long);
        		}
        	}
        	request.send();
		}

		function update_map(lat, long) {
			img = document.getElementById('mapImg');
        	if (img && map_cache) {
        		img.src = map_cache + lat + ',' + long + ',yellow';
        	}
		}
		</script>";
	
	//Put the location_update in a iframe and start the main divs
	echo "
		</head>
		<body>	
		<div id='container'>
		<div id='content'>";
		
	//If the user has not logged in and this is not the login page, display the login page 
	if (!isset($_SESSION['player_id']) and !isset($login_page)) {
	echo "<script type='text/javascript'>
				<!--
				window.location = '{$GLOBALS['WWW_ROOT']}/login.php'
				//-->
				</script>";
	}

} //end function





/*
Close all tags and display footer
*/
function page_footer() {
	$moduleRoot = "{$GLOBALS['WWW_ROOT']}/apps";
	
	
	echo '</div><!--Close content div-->
	<table id="nav">
			<tr>';
	
	//Query the applications table to determine which should be displayed
	$query = "SELECT * FROM {$GLOBALS['DB_TABLE_PREFIX']}applications 
		JOIN {$GLOBALS['DB_TABLE_PREFIX']}player_applications 
		ON {$GLOBALS['DB_TABLE_PREFIX']}applications.application_id = {$GLOBALS['DB_TABLE_PREFIX']}player_applications.application_id 
		WHERE {$GLOBALS['DB_TABLE_PREFIX']}player_applications.player_id = '$_SESSION[player_id]'";
				
	$result = mysql_query($query);	
	echo mysql_error();
	while ($app = mysql_fetch_array($result)) {
		echo "<td><a href='{$moduleRoot}/{$app['directory']}/index.php'><img src='{$moduleRoot}/{$app['directory']}/icon.png'/></a></td>";
	}
	
	//Always display the logout application		
	echo "
	<td>
		<a href = '$GLOBALS[WWW_ROOT]/logout.php'><img src = '$GLOBALS[WWW_ROOT]/theme/logout_icon.png' width = '50px'/></a>
	</td>
	</tr>
		</table>";
	
	//Scroll to the Bottom of the page if this is the IM application
	echo '
		<script type="text/javascript">
 		 //<![CDATA[
	';
	
	if (!defined('IM')) {
			echo 'window.onload = function() {setTimeout(function(){window.scrollTo(0, 1);}, 100);}';

	}
	echo '
         //]]>
		</script>';
	
	//Close remaining DIV tags	
	echo '	
	</div><!--Close nav div-->
	</div><!--Close container div-->
	</body>
	</html>';
}


/*
Close all tags and display footer without navigation
*/
function page_footer_no_nav() {
	echo '
		</div><!--Close content div-->
		</div><!--Close container div-->
		</body>
		</html>
	';
}

?>