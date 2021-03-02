Godot Lesson 6: Enemy Health
=======================================

Summary
--------

This lesson creates an enemy death scene and tracks entity health.

Prerequisites
--------------

* An entity class with one enemy (Lessons 1, 2, 3)
* An item that does damage (Lesson 5)

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/ikAJGfuc_Vg" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Resources
-----------

* Stalfos Hurt Sprite: https://sprites.retro-dragon.com/index.php/2018/08/28/stalfaux-hurt/
* Player Hurt Sprite: https://sprites.retro-dragon.com/index.php/2018/08/27/zlg-player-hurt/
* Enemy Death Sprite: https://sprites.retro-dragon.com/index.php/2018/08/29/zlg-enemy-death/


Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/6-enemy-health


Enemy Death Code
^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    extends Node2D

    # Called when the node enters the scene tree for the first time.
    func _ready():
        $anim.play("default")
        
        # connect the animation finishing to the function "destroy" send it the animation
        $anim.connect("animation_finished", self, "destroy")
        
    func destroy(animation):
        queue_free()



Entity Code
^^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    class_name entity
    extends KinematicBody2D

    var dir = directions.new()

    # "CONSTANTS"
    var SPEED = 0
    var TYPE = "ENEMY"
    var DAMAGE = null
    var MAXHEALTH = 2

    # MOVEMENT
    var movedir = Vector2.ZERO
    var knockdir = Vector2.ZERO
    var spritedir = "down"

    var hitstun = 0
    var health = MAXHEALTH
    var texture_default = null
    var texture_hurt = null


    func _ready():
        texture_default 	= $Sprite.texture
        # make the hurt texture the same name and path as the default texture
        # but replace .png with _hurt.png
        texture_hurt 	= load($Sprite.texture.get_path().replace(".png", "_hurt.png"))

    func movement_loop():
        var motion 

        # if you aren't in hitstun then move normally
        # otherwise get knocked back	
        if hitstun == 0:
            motion = movedir.normalized() * SPEED
        else:
            motion = knockdir.normalized() * 125
            
        move_and_slide(motion, Vector2.ZERO)
        
    func spritedir_loop():
        match movedir:
            Vector2.LEFT:
                spritedir = "left"
            Vector2.RIGHT:
                spritedir = "right"
            Vector2.UP:
                spritedir = "up"
            Vector2.DOWN:
                spritedir = "down"
                
    # This changes our player animation.  "animation" is a string 
    # of the sort "idle", "push", or "walk"
    func anim_switch(animation):
        var newanim = str(animation, spritedir)
        if $anim.current_animation != newanim:
            $anim.play(newanim)
            
    func damage_loop():
        # If you're in hitstun countdown the timer
        if hitstun > 0:
            hitstun -= 1
            $Sprite.texture = texture_hurt
        else:
            $Sprite.texture = texture_default
            
            # if the enemy should be dead
            if TYPE == "ENEMY" && health <= 0:
                # create the death animation, put it where the enemy was and destroy the enemy
                var death_animation = preload("res://enemies/enemy_death.tscn").instance()
                get_parent().add_child(death_animation)
                death_animation.global_transform.origin = global_transform.origin
                queue_free()

        # for any area that is overlapping the entity's hitbox
        for area in $hitbox.get_overlapping_areas():
            # Body is the area's parent - a weapon or an entity
            var body = area.get_parent()
            # if the entity isn't already hit, and the body gives damage, 
            # and the body is a different type that the entity
            if hitstun == 0 and body.get("DAMAGE") != null and body.get("TYPE") != TYPE:
                # decrease health by the body's damage
                health -= body.get("DAMAGE")
                # Set the hitstun timer
                hitstun = 10
                # set knockdir to the opposite of the entity approached
                # the body from
                knockdir = global_transform.origin - body.global_transform.origin

    # Accepts an actual item scene not the name of the scene
    func use_item(item):
        # create an instance of the item
        var newitem = item.instance()
        
        # add it to the group with item name and the id of its parent
        newitem.add_to_group(str(newitem.get_name(), self))
        
        # make it a child of the entity
        add_child(newitem)
        
        # if there are already too many items of that type on the screen, delete it
        if get_tree().get_nodes_in_group(str(newitem.get_name(), self)).size() > newitem.maxamount:
            newitem.queue_free()
