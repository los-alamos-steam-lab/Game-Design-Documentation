Godot Lesson 9: Keys and Locked Doors
=======================================

Summary
--------

This lesson sets up pickups and allows a player to hold keys and use them
to unlock doors.

Prerequisites
--------------

* A player (Lesson 2) and HUD (Lesson 8)
* Everything will make more sense with Lessons 1 through 8

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/zKPAL_YotF0" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Resources
-----------

* New Player Sprites: https://sprites.retro-dragon.com/index.php/2019/10/04/zlg-player-sprite-full-sheet/
* Key Sprite: https://sprites.retro-dragon.com/index.php/2018/08/29/zlg-key/
* Other New Sprites: https://imgur.com/a/801fBLH

Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/9-keys-and-locked-doors


Key Code
^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    extends StaticBody2D

    # Called when the node enters the scene tree for the first time.
    func _ready():
        $area.connect("body_entered", self, "body_entered")
        
    func body_entered(body):
        # I replace body.get(keys) with body.keys because I want this 
        # to fail if the player does not have a keys variable
        if body.name == "player" && body.keys > 0:
            # Use a key and then delete the door.
            body.keys -= 1
            queue_free()

Key Door Code
^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    extends StaticBody2D

    # Called when the node enters the scene tree for the first time.
    func _ready():
        $area.connect("body_entered", self, "body_entered")
        
    func body_entered(body):
        # I replace body.get(keys) with body.keys because I want this 
        # to fail if the player does not have a keys variable
        if body.name == "player" && body.keys > 0:
            # Use a key and then delete the door.
            body.keys -= 1
            queue_free()
