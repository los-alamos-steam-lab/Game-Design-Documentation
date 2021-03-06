Godot Template: Save Game
================================================

Overview 
----------

Saving and loading is a pretty important part of an RPG.  This game does not have a
save screen, but does load the game upon start and save it upon scene or room change.
There is a main save file, as well as a save file for each map area.  

Worth noting is that this template saves files to the res:// directory for easier access.  
This will need to be updated to user:// at deployment time.

Much of the save game process came directly from the Godot docs: 
https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html 

Main Scene
------------------------------------

Saving
^^^^^^^^

When a screen change is started, `Main.save_game()`_ is called. 

* If there is a current_area and include_area is true (default) 
  then call the area's save game.
* Call `Main.save()`_ in order to save details like which map area
  is loaded and where the player should start in it as well as player
  stats.
* Go through all of nodes in group 'persist.  If they are not empty, 
  have the current scene as their parent, and have a save method, 
  then call it (in our template, this only affects the player). 
* They should return a dictionary that includes:
    * "filename" : get_filename()
    * "parent" : get_parent().get_path()
    * "pos_x" : position.x 
    * "pos_y" : position.y
* Store everything in the save file and close it.  Each dictionary is 
  converted to json and written as a single line in the file.

Loading 
^^^^^^^^^

When the game starts we load the save game.  

Note that in `Main._ready()`_ we make use of yield(get_tree(), "idle_frame") 
in order to prevent race conditions. After the first yield, call `Main.load_game()`_

* If there's no save file, leave.
* Get all of the nodes in group 'persist'.  If they're not the player and 
  have a save game, then delete them.  Basically, if we didn't save them it is
  because the player destroyed them (enemies and locked doors) or picked them up 
  (keys).  If we did save them, we'll load them in a moment.
* Open the save game and read it line by line.
* If it is empty, ignore it.
* If it is for the player, call Player.load_dict()
* If it is for the current file (Main) save the line.  We'll get to it at the
  end.
* Otherwise, load the new scene and set its position. If it has a load_dict()
  call it, otherwise assume each dictionary key has a corresponding variable 
  and just assign it.
* If we saved the data for the current file (Main) load it now.  This can overwrite 
  the player position, so we wanted to wait until the end.  
* If the initial_area_path was set, then load the current_area.

Map Areas
--------------

Saving 
^^^^^^^^^^

Map Areas are saved during screen changes via Main.save_game() and teleports
before they are deleted.  

These save routines are very similar to the last stage of Main.save_game().

* Go through all of nodes in group 'persist.  If they are not empty, 
  have the current scene as their parent, and have a save method, 
  then call it.  This will include enemies and objects spawned by the 
  object placer. This will not include any grandchildren of the area.
* They should return a dictionary that includes:
    * "filename" : get_filename()
    * "parent" : get_parent().get_path()
    * "pos_x" : position.x 
    * "pos_y" : position.y
* Store everything in the save file and close it.  Each dictionary is 
  converted to json and written as a single line in the file.


Loading 
^^^^^^^^^

Map Areas are loaded when the scene is loaded (usually when the game loads 
or the player teleports.  

Note that in `maparea._ready()`_ we 
make use of yield(get_tree(), "idle_frame") in order to prevent race 
conditions. We need the object placer to finish loading scenes before we delete
them. After the yield, call `maparea.load_maparea()`_. 

These load routines are very similar to the last stage of Main.save_game().

* If there's no save file, leave.
* Get all of the nodes in group 'persist'.  If they have the current map area as
  a parent, delete them.  Basically, if we didn't save them it is
  because the player destroyed them (enemies and locked doors) or picked them up 
  (keys).  If we did save them, we'll load them in a moment.
* Open the save game and read it line by line.
* If it is empty, ignore it.
* Otherwise, load the new scene and set its position. If it has a load_dict()
  call it, otherwise assume each dictionary key has a corresponding variable 
  and just assign it.

Code 
--------

Main.save_game() 
^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func save_game(include_area = true):
        if current_area and include_area:
            current_area.call("save_maparea")
            
        var save_game = File.new()
        save_game.open(SAVE_FILE, File.WRITE)
        
        # Save stats
        var node_data = save()
        save_game.store_line(to_json(node_data))
        
        var save_nodes = get_tree().get_nodes_in_group("persist")
        for node in save_nodes:
            if node.filename.empty():
                print("--persistent node '%s' is not an instanced scene, skipped" % node.name)
                continue
            if node.get_parent() == current_area:
                print("--persistent node '%s' is in the current map area, skipped" % node.name)
                continue
            if !node.has_method("save"):
                print("--persistent node '%s' is missing a save() function, skipped" % node.name)
                continue

            node_data = node.call("save")
            save_game.store_line(to_json(node_data))
            
        save_game.close()

Main.save() 
^^^^^^^^^^^^

.. code-block:: gdscript

    func save():
        var save_dict = {
            "filename" : get_filename(),
            "inital_area_path" : current_area.get_filename(),
            "player_startx" : current_area.player_start.x,
            "player_starty" : current_area.player_start.y,
            "player_start_spritedir" : current_area.player_start_spritedir
        }

        return save_dict

Main._ready() 
^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func _ready():
        player = get_node(player)

        yield(get_tree(), "idle_frame")
        load_game()
        
        yield(get_tree(), "idle_frame")
        if !current_area:
            current_area = instance_area(inital_area_path)
            player.position = current_area.player_start
            player.spritedir = current_area.player_start_spritedir

        camera = get_node(camera)
        camera.connect("screen_change_completed", self, "screen_change_completed")


Main.load_game()
^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func load_game():
        var save_game = File.new()
        var local_save_data = null
        if not save_game.file_exists(SAVE_FILE):
            return # Error! We don't have a save to load.

        # We need to revert the game state so we're not cloning objects
        # during loading. This will vary wildly depending on the needs of a
        # project, so take care with this step.
        # For our example, we will accomplish this by deleting saveable objects.
        var save_nodes = get_tree().get_nodes_in_group("persist")

        for node in save_nodes:
            # if it is the player (our current) node we can't delete it
            # we also don't want to delete it if it doesn't have a save
            # function, because we probably haven't finished setting it up
            if player.get_filename() == node.get_filename():
                print("--persistent node '%s' is the Player node, skipped" % node.name)
                continue
            elif !node.has_method("save"):
                print("--persistent node '%s' is missing a save() function, skipped" % node.name)
                continue
            node.queue_free()


        # Load the file line by line and process that dictionary to restore
        # the object it represents.
        save_game.open(SAVE_FILE, File.READ)
        while save_game.get_position() < save_game.get_len():
            # Get the saved dictionary from the next line in the save file
            var node_data = parse_json(save_game.get_line())

            if node_data == null:
                continue

            # If it is the player node we're not creating a new instance
            if player.get_filename() == node_data["filename"]:
                player.load_dict(node_data)
                continue
            
            # If it is the local file then save the line to be loaded at the
            # end.  We're not loading it now because we want to overwrite player
            # position.
            if get_filename() == node_data["filename"]:
                local_save_data = node_data
                continue

            # Firstly, we need to create the object and add it to the tree and set its position.
            var new_object = load(node_data["filename"]).instance()
            get_node(node_data["parent"]).add_child(new_object)
            new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
            
            # If it had its own load method, use it
            # Otherwise set the remaining variables based on key names
            if new_object.has_method("load_dict"):
                new_object.load_dict(node_data)
            else:
                for i in node_data.keys():
                    if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
                        continue
                    new_object.set(i, node_data[i])
                    
        # load the local stats
        if local_save_data:
            load_dict(local_save_data)
            
        # load the current_area
        if inital_area_path:
            current_area = instance_area(inital_area_path)

        save_game.close()

maparea.save_maparea()
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func save_maparea():
        var save_game = File.new()
        save_game.open(SAVE_FILE, File.WRITE)
        
        var save_nodes = get_tree().get_nodes_in_group("persist")
        
        for node in save_nodes:
            if node.filename.empty():
                print("--persistent node '%s' is not an instanced scene, skipped" % node.name)
                continue
            if !node.has_method("save"):
                print("--persistent node '%s' is missing a save() function, skipped" % node.name)
                continue
            if node.get_parent() == self:
                var node_data = node.call("save")
                save_game.store_line(to_json(node_data))
        
        save_game.close()


maparea._ready()
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func _ready():
        SAVE_FILE = "res://" + name + ".json"
        # yield is need to allow the scene to finish loading
        # before loading the savefile.
        yield(get_tree(), "idle_frame")
        load_maparea()


maparea.load_maparea()
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func load_maparea():

        var save_game = File.new()
        if not save_game.file_exists(SAVE_FILE):
            return # Error! We don't have a save to load.

        # We need to revert the game state so we're not cloning objects
        # during loading. This will vary wildly depending on the needs of a
        # project, so take care with this step.
        # For our example, we will accomplish this by deleting saveable objects.
        var save_nodes = get_tree().get_nodes_in_group("persist")
        for i in save_nodes:
            if i.get_parent() == self:
                i.queue_free()

        # Load the file line by line and process that dictionary to restore
        # the object it represents.
        save_game.open(SAVE_FILE, File.READ)
    
        while not save_game.eof_reached():
            var node_data = parse_json(save_game.get_line())
            
            if node_data == null:
                continue
            
            # Firstly, we need to create the object and add it to the tree and set its position.
            var new_object = load(node_data["filename"]).instance()
            get_node(node_data["parent"]).add_child(new_object)
            new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
            
            # Now we set the remaining variables.
            if new_object.has_method("load_dict"):
                new_object.load_dict(node_data)
            else:
                for i in node_data.keys():
                    if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
                        continue
                    new_object.set(i, node_data[i])
        
        save_game.close()

