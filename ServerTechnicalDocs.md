# ARIS Server as a collection of Web Services #

ARIS uses [AMFPHP](http://amfphp.sourceforge.net/) for a simple PHP/MySQL development environment that provides JSON, AMF, REST and RPC web services. A set of php objects exist at [server/services/aris] and are translated into web services by AMFPHP.

For example, server/services/aris/items.php contains the Items object. In this object various methods exist for creating, searching, modifying items in an ARIS game. One method is called getItem($gameId, $itemId) and is designed to retrieve information about a specific item, provided the game id and item id.

A description of each service provided can be found in the [ARIS Services documentation](http://arisgames.googlecode.com/svn/wiki/serviceDocs/index.html)

These methods can then be used in a number of ways.

## Service Browsing ##

AMFPHP provides a service browser for debugging and trying things out. This is always found at the

**http://your_aris_server/browser**

## AMF ##

In the FLEX editor, the RemoteObject class will do the work for you provided you set up your services-config.xml file to use http://your_aris_server/gateway.php as the endpoint uri for the amfphp destination. (See editor/services-config.xml)

```
itemServer = new RemoteObject();
itemServer.source = "aris.items"; //all service names have the aris. prefix
itemServer.destination = "amfphp";
itemServer.showBusyCursor = true;

var l:Object;
l = itemServer.getItem(gid, id);
l.addResponder(resp);

```

## JSON ##

For the iPhone client we use the JSON protocol instead. For JSON, simply load the http result from accessing a specially formed URL. In the example below, notice that the arguments for getItem() are simply added in using slashes.

**http://your_aris_server/json.php/aris.items.getItem/150/23**




# Database Structure #

The database structure for ARIS should be self explanatory given you know a few details:

## The Tables ##

  * Each game has it's own set of tables which all start with 'gameId' as a prefix
    * items
    * locations - geograph placements of nodes (called plaques in editor), items and npcs (called characters in editor)
    * nodes - either a simple piece of media with text if linked to from a conversation, or a whole script if from an npc\_converstion
    * npcs
    * player\_items
    * npc\_conversations - links npcs with nodes to create a hub and spoke conversation system
    * player\_state\_changes - used by nodes, items, npcs to modify player attributes or inventory
    * qr\_codes - link to locations for when the "decoder" is used in the app
    * quests
    * requirements - criteria for when nodes, locations and quests are available in terms of records found in the player\_log.
    * folders - used only by the editor for organizing the object pallet
    * folder\_contents - used only by the editor for organizing the object pallet
  * The server instance also has a few tables that are used across all games
    * players
    * editors
    * games
    * game\_editors
    * player\_log - many requests to the server will generate a log that is recorded here. This is paired with the requirements table to make decisions about what game objects/states are available

## Data Linking ##

In ARIS, many tables use a loose linking system that you will become very accustomed with. For example, a single location can reference and link to a node, item or npc. This is accomplished by two filelds, type and type\_id.

  * type is an enum('Node','Item','Npc') and determines which table the location is referring to.
  * type\_id is the id within that table

## Special Columns ##

In both the requirements table and the player\_log table, certain columns have different meanings depending on another column. For example, in requirements, if the requirement column = 'PLAYER\_HAS\_ITEM' the requirement\_details\_1 column will be used to identify the item\_id within the items table that the player must have.

Following are the definitions of those two tables' dynamic columns.

### Requirements Table ###

| English Statement | requirement | requirement\_detail\_1 | requirement\_detail\_2 | requirement\_detail\_3 |
|:------------------|:------------|:-----------------------|:-----------------------|:-----------------------|
| Player has at least 1 of item 7 | PLAYER\_HAS\_ITEM | the item\_id           | minimum qty to qualify |                        |
| Player has less than 1 of item 7 | PLAYER\_DOES\_NOT\_HAVE\_ITEM  | the item\_id           | minimum qty to qualify |                        |
| Player has looked at the details page of item 6 at least once | PLAYER\_VIEWED\_ITEM  | the item\_id           |                        |                        |
| Player has never looked at the details page of item 4 | PLAYER\_HAS\_NOT\_VIEWED\_ITEM | the item\_id           |                        |                        |
| Player has seen plaque 4 at least once; Player has completed the script of node 8 at least once | PLAYER\_VIEWED\_NODE | the node\_id           |                        |                        |
| Player has never seen plaque 4; Player has never completed the script of node 8 | PLAYER\_HAS\_NOT\_VIEWED\_NODE | the node\_id           |                        |                        |
| Player has seen the greeting of npc 7 at least once | PLAYER\_VIEWED\_NPC | the npc\_id            |                        |                        |
| Player has never seen the greeting of npc 7| PLAYER\_HAS\_NOT\_VIEWED\_NPC | the npc\_id            |                        |                        |
| Player has taken a picture, recorded a vide or recorded audio within 10 meters of a position | PLAYER\_HAS\_UPLOADED\_MEDIA\_ITEM | latitude               | longitude              | range (in meters)      |
| The players actions have completed all the requirements for completing quest 8 | PLAYER\_HAS\_COMPLETED\_QUEST | the quest\_id          |                        |                        |