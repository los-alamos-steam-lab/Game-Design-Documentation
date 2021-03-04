Godot RPG: Creating a New Item (Weapon)
================================================

Overview
------------

Weapons are created independent of the Player, so that they can also be used by
enemies and other entities.

Creating the Scene Tree
-------------------------

An enemy extends item, so you'll need to have the basic scene tree 
required by the :doc:`Item Class</godot/RPG/template/6-item>`.  Names not in quotes should not be changed.

* "Name" is type Item
    * [optional] AnimationPlayer is type AnimationPlayer
    * Sprite is type Sprite 
    * Hitbox is type Area2D
        * CollisionShape2D is type CollisionShape2D

Exports
----------
Again, these are inherited from the :doc:`Item Class</godot/RPG/template/6-item>`.  

* DAMAGE
    * The amount the item harms an entity of a different type
* MAX_AMOUNT
    * The maximum number of the item that a single entity can have spawned at a time
* delete_on_hit
    * Signals whether the item should be deleted when it hits an entity of a different type

Script
--------

Most of the function of the item will need to be written individually for each item, but a 
basic outline of what might be expected is below.

_ready()
^^^^^^^^^
If the item has an animation (like a sword swing) then you'll want to set_physics_process(false) so that the 
animation can finish before moving on.  Alternatively, if it is waiting for the input to be released 
(like a bow) then we'll want physics process on.

start()
^^^^^^^^
This is a required function and is called by Entity.use_item().  In general, this should start 
the animation, connect signals, play sounds, and set the entity state.  An example from sword is 
below.  Again, this will serve a slightly different function for something like a bow.  We may 
even just pass it.

.. code-block:: gdscript

    func start():
        anim.connect("animation_finished", self, "destroy")
        anim.play(str("swing", get_parent().spritedir))
        sfx.play(load(str("res://items/sword_swing",int(rand_range(1,5)),".wav")))
        if get_parent().has_method("state_swing"):
            get_parent().state = "swing"

destroy()
^^^^^^^^^^
This is an optional function that can be attached to the animation_finished signal.  It sets 
the expected behavior of the item after the animation has completed (i.e. arrows moving off 
in the direction they were fired).  This is also where set_physics_process(true) would be set 
in a situation like a sword.

_physics_process()
^^^^^^^^^^^^^^^^^^^
Mostly physics process will be checking to see if the input has been released.  In the case 
of something like the sword, we'll destroy the item.  For something like a bow, we'll run the 
animation and then continue to move the arrow until it is deleted or goes off screen.


