Godot Lesson 5: Item Setup
=======================================

Summary
--------

This lesson creates a sword item that is setup to be used by both entities and players.
This sets the framework for adding other weapons and items as well.

Prerequisites
--------------

* An entity class with one enemy (Lessons 1, 2, 3)
* Everything will make more sense with Lesson 4 (knockback)

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/zauf7PR3CzM" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/5-item-setup


Item Code
^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    extends Node2D

    var TYPE = null
    var DAMAGE = 1

    #number of the item that can be owned by a single entity on the screen
    var maxamount = 1

    # Called when the node enters the scene tree for the first time.
    func _ready():
        # find out who is holding the sword
        TYPE = get_parent().TYPE
        
        # when the animation finsishes, call the function "destroy"
        $anim.connect("animation_finished", self, "destroy")
        
        #animate the sword
        $anim.play(str("swing", get_parent().spritedir))
        
        # if the parent has a state definted for swing, then set it
        if get_parent().has_method("state_swing"):
            get_parent().state = "swing"
        
    func destroy(animation):	
        # if the parent has a state definted for swing, then unset it
        if get_parent().has_method("state_swing"):
            get_parent().state = "default"
        
        #delete the item
        queue_free()


Entity Code
^^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    class_name entity
    extends KinematicBody2D

    # we put this here instead of autoloading it
    # nothing wrong with autoload, but I prefer things in the code
    var dir = directions.new()

    # "CONSTANTS"
    var SPEED = 0
    var TYPE = "ENEMY"
    # have to declare damage here so we can set it in the child scripts
    var DAMAGE = null

    # MOVEMENT
    var movedir = Vector2.ZERO
    var knockdir = Vector2.ZERO
    var spritedir = "down"

    var hitstun = 0
    var health = 1


    # Putting this here so that we can setup future calls from the 
    # child scripts and not have them fail
    func _ready():
        return

    func movement_loop():
        var motion 

        # if you aren't in hitstun then move normally
        # otherwise get knocked back	
        if hitstun == 0:
            motion = movedir.normalized() * SPEED
        else:
            motion = knockdir.normalized() * SPEED * 1.5
            
        
        # move_and_slide takes care of collisions and has you slide 
        # along walls that are blocking your path
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


Player Code
^^^^^^^^^^^^^^^^^^^^
  
.. code-block:: gdscript

    extends entity

    var state = "default"

    # ready function lets us set "constants" when the file loads
    func _ready():
        SPEED = 70
        TYPE = "PLAYER"
        
    # _physics_process is called by the game engine
    func _physics_process(delta):
        # making things neater with a state engine
        # this lets us break each state out in to its own function
        match state:
            "default":
                state_default()
            "swing":
                state_swing()
        
    func state_default():
        controls_loop()
        movement_loop()
        spritedir_loop()
        damage_loop()
        
        if movedir == Vector2.ZERO:
            anim_switch("idle")
        elif is_on_wall():
            if (spritedir == "left" and test_move(transform, Vector2.LEFT))\
            or (spritedir == "right" and test_move(transform, Vector2.RIGHT))\
            or (spritedir == "up" and test_move(transform, Vector2.UP))\
            or (spritedir == "down" and test_move(transform, Vector2.DOWN)):
                anim_switch("push")
        else: 
            anim_switch("walk")
            
        # action keys get put into project settings
        # if the key assigned to 'a' is pressed then use the sword
        if Input.is_action_just_pressed("a"):
            use_item(preload("res://items/sword.tscn"))
            

    # we want to keep the player still but allow them to take damage
    func state_swing():
        anim_switch("idle")
        damage_loop()	
        
    # controls_loop looks for player input
    func controls_loop():
        var LEFT		= Input.is_action_pressed("ui_left")
        var RIGHT	= Input.is_action_pressed("ui_right")
        var UP		= Input.is_action_pressed("ui_up")
        var DOWN		= Input.is_action_pressed("ui_down")
        
        # By adding our values together, we make it so that one key 
        # stroke does not take precidence over another, i.e. pushing 
        # left and right keys at the same time
        movedir.x = -int(LEFT) + int(RIGHT)
        movedir.y = -int(UP) + int(DOWN)

