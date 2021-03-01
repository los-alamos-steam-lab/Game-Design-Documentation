Godot Lesson 4: Knockback
=======================================

Summary
--------

This lesson creates knockback forcing the entity away from the 
attacker when hit.  Entities also do not get damage while being 
knocked back.

Prerequisites
--------------

* An entity class with one enemy (Lessons 1, 2, 3)

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/vp57qbgenOE" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/4-knockback


Entity Code
^^^^^^^^^^^^^^^^^^^^

Major Changes from the Video:  

* Declared DAMAGE because otherwise the references in entity fail.
  
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
            
        # for any body that is overlapping the entity's hitbox
        for body in $hitbox.get_overlapping_bodies():
            # if the entity isn't already hit, and the body gives damage, 
            # and the body is a different type that the entity
            if hitstun == 0 and body.get("DAMAGE") != null and body.get("TYPE") != TYPE:
                # decrease health by the body's damage
                health -= body.get("DAMAGE")
                # Set the hitstun timer
                hitstun = 10
                # set knockdir to the opposite of the entity approached
                # the body from
                knockdir = transform.origin - body.transform.origin


Player Code
^^^^^^^^^^^^^^^^^^^^

Major Changes from the Video:  

* The _ready func is used to set TYPE and other "constants"

  
.. code-block:: gdscript

    extends entity

    # ready function lets us set "constants" when the file loads
    func _ready():
        SPEED = 70
        TYPE = "PLAYER"
        
    # _physics_process is called by the game engine
    func _physics_process(delta):
        controls_loop()
        movement_loop()
        spritedir_loop()
        damage_loop()
        
        # We're setting our animation here.  I've replaced Vector2(0,-1)
        # with Vector2.UP for readability, and so forth.  These are new to godot 3.1 
        # I've also changed the order of the if statement to prioritize being
        # idle if movedir is zero and created a single (very long) if statement
        # for testing the push animation.

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

Stalfos Code
^^^^^^^^^^^^^^^^^^^^

Major Changes from the Video:  

* The _ready func is used to set DAMAGE and other "constants"
  
  
.. code-block:: gdscript

    extends entity

    var movetimer_length = 15
    var movetimer = 0

    # ready function lets us set "constants" and perform 
    # other actions when the file loads
    func _ready():
        SPEED = 40
        DAMAGE = 1
        $anim.play("default")
        movedir = dir.rand()
        
    func _physics_process(delta):
        movement_loop()
        damage_loop()
        
        # count down the movetimer every tick
        if movetimer > 0:
            movetimer -= 1
            
        # if the movetime reaches zero or the stalfos is on a wall
        # change direction and reset the timer
        if movetimer == 0 || is_on_wall():
            movedir = dir.rand()
            movetimer = movetimer_length




