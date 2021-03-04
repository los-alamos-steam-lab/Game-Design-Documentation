Godot RPG: Creating a New Map Area
================================================


Overview
------------

Creating your own area is a good start to making the game your own. 
Even if it is a very simple test area, it will help get you started with
the rest of the game, as it will define the size of your tilesets.

Drawing the Scene
---------------------

* Learn more about how to create your own tilesets and tilemaps in Godot here. 
* You'll aslo want to set your Window size to match your new aesthetic 
  (Project Settings -> General -> Display -> Window )
* Set the Camera Screen Size to match (Main Scene -> Camera -> Inspector) or make sure
  it is set to Vector2.ZERO to have the game set it for you.
* Update your player and entity speeds to match the tilesize in their inspectors.


Placing Items and Entities
-----------------------------

Using the Object Placer
^^^^^^^^^^^^^^^^^^^^^^^^^

The video learning about the object placer is here: :doc:`/godot/RPG/lessons/8-object-placer`

As a quick overview, scenes that do not need individualized (i.e. a typical
stalfaux, rather than one that only drops bombs) can be placed as tiles in the 
object placer and placed as tiles.  The name of the tile should be the path to
the scene without .tscn on the end (i.e enemies/stalfos).  At run time, the engine
will replace each tile with the appropriate scene.

Signs and Other Unique Objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Items that want their export values set uniquely need to be placed individually in the scene.  
If you want them to be persistant through save games then they need to be in the top level of the scene.

Playing the Scene
--------------------

Extending Map Area
^^^^^^^^^^^^^^^^^^^^

Attach a script to your main node for the scene and replace it with the following code:

.. code-block:: gdscript

    extends MapArea


    # Called when the node enters the scene tree for the first time.
    func _ready():
    #	SAVE_FILE = "res://" + name + ".json"
        pass

Usually you don't need to add anything else to that code.

Deleting (or editing) the Save Data 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The save data records the scene that should load.  In order to play the new scene, that data 
needs to be reset.

Find every \*\*\*.json in the project directory and delete them.  The most important one is 
game-data.json, but you'll be deleting any keys you have in your inventory so it makes sense
to reset everything.  

Alternatively, you can edit the game-data.json file to set the inital_area_path to the 
new scene or create a teleport point to the new scene in a scene the player currently has
access to.

Adding the Scene to Main 
^^^^^^^^^^^^^^^^^^^^^^^^^^

If you have deleted your save data, then you'll test your scene by setting the
inital_area_path of Main (Main -> Inspector -> Inital Area Path)


