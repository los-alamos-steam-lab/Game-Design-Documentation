Godot Lesson 3: Entity Class
=======================================

Summary
--------

This lesson moves a lot of the player movement loops into a separate entity 
class to be used my enemies and NPCs as well.

Prerequisites
--------------

* A moving player with animations (Lessons 1 and 2)

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/gJxiLIEFpv0" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/3-entity-class

Directions Code
^^^^^^^^^^^^^^^^^^^^

Major Changes from the Video:  

* Relies on built in Vector2 enums instead of declaring dir.UP and so forth
* class_name at the top makes this callable from other functions
  
.. code-block:: gdscript

    class_name directions
    extends Node

    # We didn't add the constants here because they are built into 
    # Vector2 after 3.1

    # return a random direction 
    func rand():
        var d = randi() % 4 
        match d:
            0:
                return Vector2.LEFT
            1:
                return Vector2.RIGHT
            2:
                return Vector2.UP
            3:
                return Vector2.DOWN


Entity Code
^^^^^^^^^^^^^^^^^^^^

Major Changes from the Video:  

* dir isn't an autoload, since we didn't include the vector directions in it
* class_name at the top makes this callable by other functions
* const is switched to var since 3.1 does not allow for child scripts to update const values
* We added a _ready function because we need it in the child scripts
  
.. code-block:: gdscript

    class_name entity
    extends KinematicBody2D

    # we put this here instead of autoloading it
    # nothing wrong with autoload, but I prefer things in the code
    var dir = directions.new()

    # MOVEMENT
    var movedir = Vector2.ZERO
    var spritedir = "down"

    var SPEED = 0

    # Putting this here so that we can setup future calls from the 
    # child scripts and not have them fail
    func _ready():
        pass

    func movement_loop():
        # .normalized makes it so that diagonal movement is 
        # the same length as 4-driectional movement
        var motion = movedir.normalized() * SPEED
        
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


Player Code
^^^^^^^^^^^^^^^^^^^^

Major Changes from the Video:  

* Makes use of entity class by just extending entity instead of a file path
* The _ready func is used to set SPEED and other "constants"
* Still prioritizing idle 
* Using built in Vector2 enums

  
.. code-block:: gdscript

    extends entity

    # ready function lets us set "constants" when the file loads
    func _ready():
        SPEED = 70
        
    # _physics_process is called by the game engine
    func _physics_process(delta):
        controls_loop()
        movement_loop()
        spritedir_loop()
        
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

* Makes use of entity class by just extending entity instead of a file path
* The _ready func is used to set SPEED and other "constants"
  
  
.. code-block:: gdscript

    extends entity

    var movetimer_length = 15
    var movetimer = 0

    # ready function lets us set "constants" and perform 
    # other actions when the file loads
    func _ready():
        SPEED = 40
        $anim.play("default")
        movedir = dir.rand()
         
    func _physics_process(delta):
        movement_loop()
        
        # count down the movetimer every tick
        if movetimer > 0:
            movetimer -= 1
            
        # if the movetime reaches zero or the stalfos is on a wall
        # change direction and reset the timer
        if movetimer == 0 || is_on_wall():
            movedir = dir.rand()
            movetimer = movetimer_length



