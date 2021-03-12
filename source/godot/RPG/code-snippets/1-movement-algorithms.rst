RPG Snippets: Entity Movement
===============================


Setup
------------

Entities want to move and a lot of entity movement algortihms have a fair bit 
of overlap, so it's best to place them in the :doc:`Entity Class</godot/RPG/template/3-entity>`.
We'll want to add a few variables to the Entity Class as well:

onready
^^^^^^^^^

* player: The player node.  Usually "get_node("/root/Main/Player")"
* Main: The Main node.  Usually "get_node("/root/Main/")"

variables
^^^^^^^^^^

* rng = RandomNumberGenerator.new()
* movetimer_length: The length the movetimer runs for
* movetimer_range: An array of length 2.  The first element is minimum movetime and the second is max.
* movetimer: The current time remaining on the movetimer 
* movetarget_radius: A circle around the target that the entity can pick a spot on and aim for (measured in tiles).
* movetarget_radius_range: Two circles that comprise a donut around the target that an entity can pick any spot in and aim for (measured in tiles).

constants
^^^^^^^^^^^

* Main.TILE_SIZE: expected tile size.  Used as a multiplier for movement.

functions
^^^^^^^^^

We'll be reusing several functions for our movement algorithms.  They're stored here.

reset_movetimer():
"""""""""""""""""""""

Resets the movetimer.  

.. code-block:: gdscript 

    func reset_movetimer(flag_list = []):
        if movetimer_range and not "ignore_range" in flag_list:
            # return a random number between movetimer_range[0] and movetimer_range[1] inclusive
            movetimer = rng.randi_range(movetimer_range[0], movetimer_range[1])
        else:	
            movetimer = movetimer_length

rand_direction()
""""""""""""""""""
This has been switched over to a list that allows for random choice.  It uses the same mechanism as 
the :doc:`Enemy Drops</godot/RPG/template/4-enemy-drops>` algorithm, although it has been simplified 
as we do not need our choice to be weighted.

* flag_list can contain:
    * ignore_range 


.. code-block:: gdscript

    func rand_direction(dir_list):
        var random_dir_list = []
        if "horizontal" in dir_list:
            random_dir_list.append(Vector2.LEFT)
            random_dir_list.append(Vector2.RIGHT)
        if "vertical" in dir_list:
            random_dir_list.append(Vector2.UP)
            random_dir_list.append(Vector2.DOWN)
        if "diagonal" in dir_list:
            random_dir_list.append(Vector2.LEFT + Vector2.UP)
            random_dir_list.append(Vector2.RIGHT + Vector2.UP)
            random_dir_list.append(Vector2.LEFT + Vector2.DOWN)
            random_dir_list.append(Vector2.RIGHT + Vector2.DOWN)
        
        var index = randi() % random_dir_list.size()
        # return a random element from the list
        return(random_dir_list[index])
            
            

loop_random_direction()
----------------------------
This function allows for movement in up to 8 directions with a fixed or randomized movetimer.
Entities can move horizontally, vertically, diagonally, or any combination of all three. If 
movetimer_range is set, then a time within the range will be randomly chosen.  Otherwise, movetimer 
will be used.

Arguments
^^^^^^^^^^^^

* dir_list can contain:
    * horizontal
    * vertical 
    * diagonal 
* flag_list can contain:
    * ignore_range 
* target defaults to player 

Code
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript 

    func loop_random_direction(dir_list, flag_list = [], target = player):	
        if movetimer > 0:
            movetimer -= 1
        if movetimer == 0 || is_on_wall():
            movedir = rand_direction(dir_list)
            reset_movetimer(flag_list)



loop_follow_target()
----------------------------
This function lets the entity follow a target (currently must be in the scene tree, long term 
this should also be able to be a specific tile the entity might range around).  

Setting the 
movetimer_length to a low number and the movetarget_radius to 0 will make the entity follow the 
target exactly.  Making the movetimer length longer will cause it to be slow in shifting directions.
Setting the movetarget_radius to be greater will cause the enemy to be near the target without 
intentionally touching it although it could go through the target to get to the point it is aiming for.

The arguments in dir_list affect the path the entity takes to get to the player.  It can track horizontally, 
vertically, both, diagonally, and in 8 directions as well as just beeline directly for the player.  
If beeline is set all other options will be ignored.

Arguments
^^^^^^^^^^^^

* dir_list can contain:
    * beeline (this takes precedence over the others)
    * horizontal
    * vertical 
    * diagonal
* flag_list can contain:
    * ignore_range 
    * ignore_radius_range
* target defaults to player

Code
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript 

    func loop_follow_target(dir_list, flag_list = [], target = player):
        var multiplier = 0
        if movetimer > 0:
            movetimer -= 1
        if movetimer == 0 || is_on_wall():
            if movetarget_radius_range and not "ignore_radius_range" in flag_list:
                # return a random number between movetimer_range[0] and movetimer_range[1] inclusive
                multiplier = rng.randi_range(movetarget_radius_range[0], movetarget_radius_range[1])
            else:	
                multiplier = movetarget_radius
            
            var offset_vector = Vector2(rng.randi_range(-100, 100), rng.randi_range(-100, 100)).normalized() * multiplier * Main.TILE_SIZE
            
            var targetdir = target.global_position + offset_vector - global_position
            if "beeline" in dir_list:
                movedir = targetdir.normalized()
            elif 'horizontal' in dir_list and not 'vertical' in dir_list and not 'diagonal' in dir_list:
                movedir = Vector2(targetdir.x, 0).normalized()
            elif not 'horizontal' in dir_list and 'vertical' in dir_list and not 'diagonal' in dir_list:
                movedir = Vector2(0, targetdir.y).normalized()
            elif not 'horizontal' in dir_list and not 'vertical' in dir_list and 'diagonal' in dir_list:
                # force x and y to be 1 or -1
                var targetx = Vector2(targetdir.x, 0).normalized()
                var targety = Vector2(0, targetdir.y).normalized()
                movedir = (targetx + targety).normalized()
            elif 'horizontal' in dir_list and 'vertical' in dir_list and not 'diagonal' in dir_list:
                if abs(targetdir.x) > abs(targetdir.y):
                    movedir = Vector2(targetdir.x, 0).normalized()
                else:
                    movedir = Vector2(0, targetdir.y).normalized()
            elif 'horizontal' in dir_list and 'vertical' in dir_list and 'diagonal' in dir_list:
                
                # in all of these equations .414 is the tangent of a 22.5deg angle
                # we're determining if we are going to use horizontal, vertical, or diagonal
                
                # horizontal
                if .414 * abs(targetdir.x) > abs(targetdir.y):
                    movedir = Vector2(targetdir.x, 0).normalized()
                # vertical
                elif .414 * abs(targetdir.y) > abs(targetdir.x):
                    movedir = Vector2(0, targetdir.y).normalized()
                # diagonal
                else:
                    var targetx = Vector2(targetdir.x, 0).normalized()
                    var targety = Vector2(0, targetdir.y).normalized()
                    movedir = (targetx + targety).normalized()
            else:
                print("dir_lst (" + str(dir_list) + ") does not contain a valid set of directions")
            reset_movetimer(flag_list)
