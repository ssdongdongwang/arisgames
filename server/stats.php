<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="utf-8">
<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" />

<link rel="stylesheet" href="./stats.css">

<?php

$CURDIR = __DIR__ . DIRECTORY_SEPARATOR;

$db = 'server';

require($CURDIR . 'config.class.php');
$sqlLink = mysql_connect(Config::dbHost, Config::dbUser, Config::dbPass) or die('MySQL error: ' . mysql_error());
mysql_select_db($db) or die('MySQL error: ' . mysql_error());

?>

<script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">

function initialize()
{
  var latlng = new google.maps.LatLng(0,0);
  var myOptions = {
    zoom: 2,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.SATELLITE };

  var map = new google.maps.Map(document.getElementById("mapContainer"), myOptions);

  <?php generatePlayerLocations(); ?>
  <?php generateGameLocations(); ?>
}

</script>

</head>

<body onload="initialize()">

<div id="header" >
  <a href="http://arisgames.org"><img src="http://arisgames.org/wp-content/uploads/2010/08/ARISLogo1.png" border="0" class="png" alt="ARIS - Mobile Learning Experiences" /></a>   
  <span id="logotext">stats</span>
</div>

<div id="mapContainer"></div>

<div id="mainStatsContainer">

  <div id="totalPlayers">
    <p class="bigNum"><span style="color: #FF9900"><?php generatePlayersTotal(); ?></span></p>
    <p class="bigText">players</p>
  </div>
    
  <div id="totalGames">
    <p class="bigNum"><span style="color: #336699"><?php generateGamesTotal(); ?></span></p>
    <p class="bigText">games</p>  
  </div>
  
  <div id="totalEditors">
    <p class="bigNum"><span style="color: #7BB31A"><?php generateEditorsTotal(); ?></span></p>
    <p class="bigText">editors</p>
  </div>
  
</div>

<div id="topTenGames">
  <h1>Top 10 games</h1>
  
  <button>day</button>
  <button>week</button>
  <button>month</button>
  <button>all time</button>
  
  <?php generateTopGames(); ?>
  
</div>

<!--
<div id="liveFeedContainer">
  <h1>Live feed</h1>
</div>
 -->
</body>
</html>

<?php


function generatePlayerLocations()
{
  $longitudeArrayName = 'longitudeArray';
  $latitudeArrayName = 'latitudeArray';

  // do not include locations that are test locations (0,0)
  $query = 'SELECT latitude, longitude
            FROM players
            WHERE latitude <> 0
            AND longitude <> 0';

  $result = mysql_query($query);

  while ($row = mysql_fetch_object($result))
  {
    echo 'new google.maps.Marker({ position: new google.maps.LatLng(' . $row->latitude . ',' . $row->longitude . '), map: map, icon: \'http://arisgames.com/stats/smiley_happy.png\' });' . "\n";
  }
}

function generateGameLocations()
{
  $query1 = 'SELECT game_id FROM games';
  $result1 = mysql_query($query1);
  
  while ($game = mysql_fetch_object($result1))
  {      
    $query2 = 'SELECT longitude, latitude FROM ' . $game->game_id . '_locations LIMIT 1';
    $result2 = mysql_query($query2);
    
    if (mysql_num_rows($result2) == 1)
    {
      $row = mysql_fetch_object($result2);
      
      if ($row->latitude != 0 && $row->longitude != 0)
      {      
        echo 'new google.maps.Marker({
              position: new google.maps.LatLng(' . $row->latitude . ',' . $row->longitude . '), 
              map: map,
              icon: \'http://arisgames.com/stats/videogames.png\' });' . "\n";
      }
    }
  }
}

function generateGamesTotal()
{
  $query = 'SELECT COUNT(DISTINCT game_id) AS count FROM games';
  $result = mysql_query($query);
  
  $numGames = mysql_fetch_object($result)->count;
  
  echo $numGames;
}

function generatePlayersTotal()
{
  $query = 'SELECT COUNT(DISTINCT player_id) AS count FROM players';
  $result = mysql_query($query);
  
  $numPlayers = mysql_fetch_object($result)->count;
  
  echo $numPlayers;
}

function generateEditorsTotal()
{
  $query = 'SELECT COUNT(DISTINCT editor_id) AS count FROM editors';
  $result = mysql_query($query);
  
  $numEditors = mysql_fetch_object($result)->count;
  
  echo $numEditors;
}

function generateTopGames()
{
  $query = '
	  SELECT games.name AS name, COUNT(DISTINCT player_id) AS count
	  FROM   player_log, games
	  WHERE player_log.game_id = games.game_id 
	  AND date_sub(curdate(), INTERVAL 1 WEEK) <= timestamp
	  AND NOW() >= timestamp
	  GROUP BY player_log.game_id
	  HAVING count > 1
	  ORDER BY count DESC';

  $result = mysql_query($query);

  $counter = 0;

  while ($game = mysql_fetch_object($result))
  {
	  $counter++;
	  $name = $game->name;
	  $count = $game->count;
	  echo "<div class=\"topTenElement\">\n";
	  echo '<div class="topTenNum">' . $counter . "</div>\n";
	  echo '<div class="topTenGameName">' . $name . "</div>\n";
	  echo '<div class="topTenGameCount">' . $count ."</div>\n";
	  echo "</div>\n";
  }
}


?>


