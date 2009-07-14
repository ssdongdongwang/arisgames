<?php

require_once('common.php');
$prefix = $DB_TABLE_PREFIX;

function run_query($query) {
	
	mysql_query($query);
	
	if (mysql_error()) {
		echo '<h1>There was a problem</h1>';
		echo '<p>Could it be you have already configured these tables?</p>';
		echo mysql_error();
	}
	else {
		echo '<p>Query ran successfully.</p>';
	}
}



if (isset($_REQUEST['action']) == FALSE){
	//Display the form
	echo '<h1>Create tables for a new game</h1>';
	echo "<p>You are about to create tables for the prefix: {$prefix}</p>
			<p>If you would like to change this, edit the common.php file first</p>";
	echo "<p><a href = '{$_SERVER['PHP_SELF']}?action=INSTALL'>Install the MYSQL Tables</a><p>";
	echo "<p><a href = '{$_SERVER['PHP_SELF']}?action=UPDATE6638'>Update the MYSQL Tables for Latitude and Longitude (Build 6638 or higher)</a><p>";
	echo "<p><a href = '{$_SERVER['PHP_SELF']}?action=UPDATE6639'>Update the MYSQL Tables for Dynamic Applications (Build 6639 or higher)</a><p>";

}

else if ($_REQUEST['action'] == "UPDATE6638") {
	$query = "ALTER TABLE {$prefix}players 
			ADD COLUMN latitude DOUBLE AFTER last_location_id,
 			ADD COLUMN longitude DOUBLE AFTER latitude;";
	run_query($query);

}

else if ($_REQUEST['action'] == "UPDATE6639") {
	//Insert the tables that support adding applications
	$query = "
	CREATE TABLE {$prefix}applications (
	  application_id int(10) unsigned NOT NULL auto_increment,
	  name varchar(25) default NULL,
	  directory varchar(25) default NULL,
	  PRIMARY KEY  (application_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	$query = "
	CREATE TABLE {$prefix}player_applications (
	  player_id int(10) unsigned NOT NULL default 0,
	  application_id int(10) unsigned NOT NULL default 0,
	  PRIMARY KEY  (player_id,application_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
}


else if ($_REQUEST['action'] == "INSTALL") {
	//Insert the tables
	$query = "
	CREATE TABLE {$prefix}events (
	  event_id int(10) unsigned NOT NULL auto_increment,
	  description tinytext COMMENT 'This description is not used anywhere in the game. It is simply for reference.',
	  PRIMARY KEY  (event_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	$query = "
	CREATE TABLE {$prefix}items (
	  item_id int(11) unsigned NOT NULL auto_increment,
	  name varchar(25) default NULL,
	  description text,
	  media varchar(50) NOT NULL default 'item_default.jpg',
	  PRIMARY KEY  (item_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	
	$query = "
	CREATE TABLE {$prefix}locations (
	  location_id int(11) NOT NULL auto_increment,
	  media varchar(30) default NULL,
	  name varchar(50) default NULL,
	  description tinytext,
	  require_event_id int(10) unsigned default NULL,
	  remove_if_event_id int(10) unsigned default NULL,
	  latitude DOUBLE NOT NULL default '0',
	  longitude DOUBLE NOT NULL default '0',
	  PRIMARY KEY  (location_id),
	  KEY require_event_id (require_event_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	$query = "
	CREATE TABLE {$prefix}log (
	  log_id int(11) unsigned NOT NULL auto_increment,
	  name tinytext,
	  description text,
	  text_when_complete tinytext NOT NULL COMMENT 'This is the txt that displays on the completed quests screen',
	  media varchar(50) default 'quest_default.jpg',
	  require_event_id int(11) unsigned default NULL,
	  add_event_id int(10) unsigned default NULL,
	  complete_if_event_id int(10) unsigned default NULL COMMENT 'If the specified event is present, this quest will move to the completed quests area',
	  PRIMARY KEY  (log_id),
	  KEY require_event_id (require_event_id),
	  KEY complete_if_event_id (complete_if_event_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	$query = "
	CREATE TABLE {$prefix}nodes (
	  node_id int(11) unsigned NOT NULL auto_increment,
	  force_layout varchar(20) default NULL,
	  title varchar(100) default NULL,
	  text text,
	  opt1_text varchar(100) default NULL,
	  opt1_node_id int(11) unsigned default NULL,
	  opt2_text varchar(100) default NULL,
	  opt2_node_id int(11) unsigned default NULL,
	  opt3_text varchar(100) default NULL,
	  opt3_node_id int(11) unsigned default NULL,
	  add_item_id int(11) unsigned default NULL,
	  remove_item_id int(11) unsigned default NULL,
	  require_item_id int(11) unsigned default NULL,
	  required_condition_not_met_node_id int(11) unsigned default 
	  		NULL COMMENT 'If an item, event or string is required but the player doesn''t have it, go to this node',
	  add_event_id int(11) unsigned default NULL,
	  remove_event_id int(11) unsigned default NULL,
	  require_event_id int(10) unsigned default NULL,
	  require_answer_string varchar(50) default NULL,
	  require_answer_correct_node_id int(10) unsigned default NULL,
	  require_location_id int(10) unsigned default NULL,
	  media varchar(25) default 'mc_chat_icon.png',
	  PRIMARY KEY  (node_id),
	  KEY require_event_id (require_event_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	$query = "
	CREATE TABLE {$prefix}npc_conversations (
	  npc_id int(10) unsigned NOT NULL default 0,
	  node_id int(10) unsigned NOT NULL default 0,
	  text tinytext NOT NULL,
	  require_event_id int(10) unsigned default NULL,
	  require_item_id int(10) unsigned default NULL,
	  require_location_id int(10) unsigned default NULL,
	  remove_if_event_id int(9) default NULL,
	  PRIMARY KEY  (npc_id,node_id),
	  KEY require_event_id (require_event_id,require_item_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);

	
	
	
	$query = "
	CREATE TABLE {$prefix}npcs (
	  npc_id int(10) unsigned NOT NULL auto_increment,
	  name varchar(30) NOT NULL default '',
	  description tinytext,
	  text tinytext,
	  location_id int(10) unsigned default NULL,
	  media varchar(30) default NULL,
	  require_event_id mediumint(9) default NULL,
	  PRIMARY KEY  (npc_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);

	
	
	$query = "
	CREATE TABLE {$prefix}player_events (
	  player_id int(10) unsigned NOT NULL default 0,
	  event_id int(10) unsigned NOT NULL default 0,
	  timestamp TIMESTAMP DEFAULT NOW(),
	  PRIMARY KEY  (player_id,event_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);

	
	
	$query = "	
	CREATE TABLE {$prefix}player_items (
	  player_id int(11) unsigned NOT NULL default 0,
	  item_id int(11) unsigned NOT NULL default 0,
	  timestamp TIMESTAMP DEFAULT NOW(),
	  PRIMARY KEY  (player_id,item_id),
	  KEY player_id (player_id),
	  KEY item_id (item_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	
	$query = "
	CREATE TABLE {$prefix}players (
	  player_id int(11) unsigned NOT NULL auto_increment,
	  first_name varchar(25) default NULL,
	  last_name varchar(25) default NULL,
	  photo varchar(25) default NULL,
	  password varchar(32) default NULL,
	  user_name varchar(30) default NULL,
	  last_location_id int(11) default NULL,
	  latitude DOUBLE default NULL,
      longitude DOUBLE default NULL,
	  PRIMARY KEY  (player_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	
	$query = "
	CREATE TABLE {$prefix}scan (
	  scan_id int(11) unsigned NOT NULL auto_increment,
	  require_event_id int(10) unsigned default NULL,
	  set_event_id int(10) unsigned default NULL,
	  title varchar(30) NOT NULL default '',
	  media varchar(30) default NULL,
	  PRIMARY KEY  (scan_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	$query = "
	CREATE TABLE {$prefix}applications (
	  application_id int(10) unsigned NOT NULL auto_increment,
	  name varchar(25) default NULL,
	  directory varchar(25) default NULL,
	  PRIMARY KEY  (application_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	$query = "
	CREATE TABLE {$prefix}player_applications (
	  player_id int(10) unsigned NOT NULL default 0,
	  application_id int(10) unsigned NOT NULL default 0,
	  PRIMARY KEY  (player_id,application_id)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8";
	run_query($query);
	
	
	
}

	

?>