# Introduction #

These are the design mockups for the next iteration of the ARIS authoring tool. They were made using the Balsalmic tool.

## Main Screen ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/main.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/main.png)

  * This is the layout for the main screen, the user's "homebase". Notice the main toolbar at the top of the window, which will be persistent.
  * The left hand column-window organizer is an area which allows users to create new objects (plaques, characters and items).
  * Users can create these objects by clicking the "new object" button, and the object will appear. in the organizer column.
  * Users may drag and drop the objects into the map.
  * Selecting an NPC or the Quests Button will replace the Google Map with the Conversation Map or the Quest Map
  * Selecting an Item, Plaque from the Objects Pallet, A script from the Conversation Map or a Quest from the Quest Map will pull out a object detail editor

## Map Screen ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/map.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/map.png)

  * Users can drag objects from the left-hand column organizer window into the map window.
  * The objects are click-and-draggable at any time within the map window.
  * The object icon remains simultaneously in the left-hand column organizer and the map window.
  * Within the map window, when an object is double-clicked then the Placemark Editor appears (convention similar to double-clicking markers in Google Maps).
  * If the player selects "new" character/plaque/item within the map area, then the object icon appears on the map and the left-hand organizer at the same time.

## Quest Map ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/quest_map.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/quest_map.png)

  * On the client, the quests display as a simple list on the ARIS starting tab. Quests direct players what to do next and act as a log for what they have already done. For example, a quest might tell the player to find a character, then change to completed once that character has been found.
During authoring, the tree view of quests will help the author to record their direction and visualize the timeline of the story.
  * Quests aren't necessarily linear. These quests may not be completed in order by a future player. Only the requirements dictate the secuence.
  * There will likely be more than one quest.
  * Quests can be "active" but not complete.
  * Completing one quest means that one is completed and another becomes simultaneously active.
  * The first quest node is typically a "Welcome" node, containing introductory text. The last node is an "end" node.
  * Clicking on a quest node opens/zooms in on a node and text editing space is viewed. The user can author: an icon, a title, description when active, and description when complete.
  * This should support rich text (Bold, italic, large and small).
  * Two square nodes, connected, appear first time quests are opened for a game. A welcome/start node and an end node.
  * Every node has an "add quest" button on the bottom.

## NPC Map ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/npc.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/npc.png)

  * After the user selects to view the "Character" window, a flowchart-looking screen appears in which nodesn and connecting arrows are the main materials users create with.
  * The primary purpose of this screen is to help the user create a simulated conversation that will occur between the future player and a non-player character (NPC).
  * Some users will use this screen to create a one-way conversation, where the NPC does all of the talking.
  * Other users will use this screen to create a 2-way conversation, where the NPC talks, and the player is given decision-options as a way to interact with the NPC.
  * Double-clicking on a "script circle" will create an expanded script editor that facilitates text and image editing.
  * Requirements can also be authored here. As with the Quest editor, the user should click on the arrow-line where it says something like "requirements" so that a requirement editor window will expand and appear.

## Script Editor ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/script.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/script.png)

## Plaque Screen ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/plaque.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/plaque.png)

  * The plaque editor is very similar to the item editor. One main difference is that plaques are not droppable or destroyable.
  * The user can choose for the player to receive an object upon interaction with the plaque. The player could receive media (image/audio/video) or an item.

## Item Screen ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/item.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/item.png)

  * The item screen lets users author the text and media (images, audio, or video) that will appear as a plaque. As they edit, users will be able to see how their authored content will be viewed by players.
  * When users click in the "add media" space, a media editor will expand and appear, giving the user options to add images, audio, or video.
  * If the user clicks in the "text" area of the editor, a blinking cursor will appear, indicating that the user can type in text.
  * Users can also determine whether the items will be droppable or destroyable by future players. Users click the "done" button to return to the map editor.


## Quest Editor ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/quest.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/quest.png)



## Place mark Editor ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/placemark.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/placemark.png)

  * The object editor appears when users double click on an object (character, item or plaque) within the map window.
  * The user can author the name and description of the object within text boxes.
  * The user can choose the quantity for items (not for characters or plaques). For example, an item of 10 gold coins could be authored.
  * The user can choose to "hide" the object from the player's view (but in play, the object could be triggered if the player was in proximity)
  * The user can choose to put requirements around the object, giving it prerequisites.

## Media Picker / Icon Picker ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/media_picker.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/media_picker.png) ![http://arisgames.googlecode.com/svn/wiki/editorMockups/icon_picker.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/icon_picker.png)


  * The media picker window appears when it is selected during the editing of a character, item, or plaque.
  * The icon picker window appears when an icon of the object editor is clicked.

## Requirements Selection ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/requirements.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/requirements.png)

  * Requirements can be assigned to characters, items and plaques on the map screen.
  * Within character conversations of the NPC editor, requirements can also be assigned to specific scripts.
  * First the user selects the type of requirement
    * player has (not) seen plaque (node)
    * player has (not) seen script (node)
    * player has (not) talked with npcplayer has (not) seen itemplayer has (doesn't have) itemSecondly the user selects the id or parameters to complete the requirement statement
  * The first selection determines the options given in the second drop down. For example: PLAYER\_HAS\_ITEM will return a list of all the items in the second drop down
  * Users can delete any requirement at any time.
  * Requirement sets use the AND operator by default. For example, player has seen item: key AND has talked with npc:joe

## Giving / Taking Items ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/give_take_items.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/give_take_items.png)


## Game Editing Permissions ##

![http://arisgames.googlecode.com/svn/wiki/editorMockups/permissions.png](http://arisgames.googlecode.com/svn/wiki/editorMockups/permissions.png)

  * The user can view authors granted permission to edit the game.
  * The user can select users to add to the game, and click the arrow to finish.

## Game Backup / Restore ##

  * We want to allow users to backup and restore their games.
  * Backup should be done from both the game selection screen as wll as the file bar of the main game editor screen.
  * Restore should be done from the game selection screen