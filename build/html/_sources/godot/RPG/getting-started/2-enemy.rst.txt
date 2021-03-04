Godot RPG: Creating a New Enemy
================================================


Overview
------------

Creating your own area is a good start to making the game your own. 
Even if it is a very simple test area, it will help get you started with
the rest of the game, as it will define the size of your tilesets.

Creating the Scene Tree
-------------------------

An enemy extends entity, so you'll need to have the basic scene tree 
required by the :doc:`Entity Class</godot/RPG/template/3-entity>`.  
Names not in quotes should not be changed.

* "Name" is type Entity
    * AnimationPlayer is type AnimationPlayer
    * Sprite is type Sprite 
    * CollisionShape2D is type CollisionShape2D
    * Hitbox is type Area2D
        * CollisionShape2D is type CollisionShape2D
        * [optional] RayCast2D is type RayCast2D


Exports
----------
Again, these are inherited from the :doc:`Entity Class</godot/RPG/template/3-entity>`.  

* TYPE
    * Defaults to "ENEMY" shouldn't need set.
* HURT_SOUND
    * Defaults to "res://enemies/enemy_hurt.wav" shouldn't need set.
* MAX_HEALTH
    * Default is 1, can range between 0.5 and 20 and is incremental by 0.5
* SPEED 
    * How fast the entity moves on the screen
* DAMAGE
    * The amount the entity harms an entity of a different type
* ITEM_DROP_PERCENT
    * The chance of an enemy dropping something when they die 
* ITEM_DROP_WEIGHT
    * Dictionary: the key is the scene path (-.tscn) to a pickup and the value is the weight of the pickup
    * This is covered more in :doc:`/godot/RPG/template/4-enemy-drops`

Animation
-------------

You'll need to decide if your enemy will have a very simple flip animation 
like the Stalfaux, something complex like the Player, or something in between.

If you plan to do complex animations for a lot of your enemmies, then it may make 
sense to make a "template" enemy so as to reuse all of the animations in 
the animation player.

A reminder on how to set up animations can be found in :doc:`/godot/RPG/lessons/2-animations`
and suggestions for basic animation spritesheets will be coming shortly.

Script
--------

Enemies inherit a lot of their functionality from Entity, but the basic script should
include a few things.

_ready()
^^^^^^^^

At a minimum, _ready() should set the enemy animation.

_physics_process()
^^^^^^^^^^^^^^^^^^^^

At a minimum, it should probably look like this.  Exceptions would be made 
for non moving enemies, enemies that don't take damage, or other unique behaviors.

Movement and damage loops are inherited from entity.  The controls loop is local.

.. code-block:: gdscript

  func _physics_process(delta):
    loop_movement()
    loop_damage()	
    loop_controls()

_loop_controls()
^^^^^^^^^^^^^^^^^^

This loop determines the movement of your entity.  Ideas for various movement
algorithms will be documented soon.

