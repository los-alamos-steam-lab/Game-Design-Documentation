Godot Template: Teleporting
================================================

Overview 
----------

The teleport scene allows the player to transition from one map area 
to another, or to jump around within a single map area.  The code by itself
can be reused for doorways into and out of houses and other similar transistions.

Scene Tree
--------------------

* teleport is type Area2D
    * Sprite is type Sprite
    * CollisionShape2D is type CollisionShape2D

Exports
----------
Because of these exports, teleports cannot be placed using the
object placer, but must be placed directly into the map area.

* dest_scene
    * FILE: The scene that the player will teleport to.
* dest_position
    * Vector2: The new player position.
* dest_spritedir
    * STRING Enum: The direction the player should face.
  

How it Works
--------------

When the player enters the teleport tile, it triggers `Main.teleport()`_ 
which:

* Pauses the tree 
* Saves the current area and deletes it.
* Loads the new area and sets the player position and direction
* Unpauses the tree

Main.teleport() can be used by other scripts (such as a door) as well.

Code 
--------

teleport.gd 
^^^^^^^^^^^^

.. code-block:: gdscript

    extends Area2D

    export(String, FILE) var dest_scene
    export(Vector2) var dest_position
    export(String, "Up", "Down", "Left", "Right")	var  dest_spritedir = "Down"

    var main_scene  := "/root/Main"

    # Called when the node enters the scene tree for the first time.
    func _ready():
        connect("body_entered", self, "body_entered")
        
    func body_entered(body):
        if body.name == "Player":
            # Pickup the key and then delete it.
            get_node(main_scene).call("teleport", dest_scene, dest_position, dest_spritedir)

Main.teleport() 
^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func teleport(new_scene_path, new_position, new_spritedir):
        get_tree().paused = true
        if current_area:
            current_area.call("save_maparea")
            current_area.queue_free()
            yield(current_area, "tree_exited")
        
        var new_area = instance_area(new_scene_path)
        player.position = new_position
        player.state = "default"
        current_area = new_area
        player.spritedir = new_spritedir
        get_tree().paused = false	
