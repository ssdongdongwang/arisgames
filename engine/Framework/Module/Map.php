<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Framework_Module_Main
 *
 * @author      Kevin Harris <klharris2@wisc.edu>
 * @author		David Gagnon <djgagnon@wisc.edu>
 * @copyright   Joe Stump <joe@joestump.net>
 * @package     Framework
 * @subpackage  Module
 * @filesource
 */


class Framework_Module_Map extends Framework_Auth_User
{
    /**
     * __default
     * Displays a map, we didn't come here with a location to display
     *
     * @access      public
     * @return      mixed
     */
    public function __default()
    {
    	$site = Framework::$site;
    	$user = Framework_User::singleton();

		$this->title = 'Current Location';
		
		// Set up a marker for each location in the locations table
		$sql = Framework::$db->prefix("SELECT * FROM _P_locations 
			LEFT OUTER JOIN _P_player_events ON 
				_P_locations.require_event_id = _P_player_events.event_id
			WHERE latitude != '' AND longitude != ''
				AND (require_event_id IS NULL OR player_id = {$user->player_id})
				AND (_P_locations.remove_if_event_id IS NULL 
									  OR _P_locations.remove_if_event_id NOT IN (SELECT event_id FROM _P_player_events WHERE player_id = {$user->player_id}))
				AND hidden != '1'");
		$rows = Framework::$db->getAll($sql);
		$this->allLocations = $rows;

		$mapPath = 'http://maps.google.com/staticmap?maptype=mobile&size='
			. $site->config->aris->map->width . 'x' 
			. $site->config->aris->map->height . '&key=' 
			. $site->config->aris->map->googleKey . '&markers=';
	 	$colors = array('green', 'purple', 'yellow', 'blue', 'gray', 'orange', 'red', 'white', 'black', 'brown');
		$letters = array('a','b','c','d','e','f','g','h','i','j','k');
		
		$i = 0;
		foreach ($rows as $row) {
			$lat = $row['latitude'];
			$long = $row['longitude'];
			$name = $row['name'];
			$lid = $row['location_id'];
			// add a marker (google seems to forgive the trailing | if it exists)
			$mapPath .= "$lat,$long,{$colors[$i]}{$letters[$i]}|";
			$i++;
		}

		// Cache the map_path for later updates
		$this->mapPathCache = $mapPath;
	
		// Set up a player icon and look for a matching location
		if (!empty($user->latitude) && !empty($user->longitude)) {
			$mapPath .= $user->latitude . ',' . $user->longtitude . ','
				. $site->config->aris->map->playerColor;
		}
		
		$this->mapPath = $mapPath;
		
		$this->loadLocationAdmin($user);
    }
    
    
    /**
     * Loads the administration apps for the default view.
     */
    protected function loadLocationAdmin($user) {
    	if ($user->authorization > 0) {
    		$applications = array();
    		$applications[] = array('directory' => 'Map',
    			'name' => 'New', 'event' => 'addLocation');
    			
    		$this->adminApplications = $applications;
    	}
    }
	
	
    public function addLocation() {
    	$site = Framework::$site;
		
    	$this->title = 'Add New Location';
    	$this->mediaFiles = $this->getSiteMediaFiles();
		
    	$this->requireEvents = $this->getEvents();
    	$this->removeEvents = $this->requireEvents;
    }
	
	
}//class
?>
