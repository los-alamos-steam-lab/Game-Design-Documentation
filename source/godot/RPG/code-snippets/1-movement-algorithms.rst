Setup
------------

Entities want to move and a lot of entity movement algortihms have a fair bit 
of overlap, so it's best to place them in the :doc:`Entity Class</godot/RPG/template/3-entity>`.
We'll want to add a few variables to the Entity Class as well:

* movetimer_length: The length the movetimer runs for
* movetimer_range: An array of length 2.  The first element is minimum movetime and the second is max.
* movetimer: The current time remaining on the movetimer 


Random Movement
---------------------
This function allows for movement in up to 8 directions with a fixed or randomized movetimer.
Entities can move horizontally, vertically, diagonally, or any combination of all three. If 
movetimer_range is set, then a time within the range will be randomly chosen.  Otherwise, movetimer 
will be used.

rand_direction has been updated for this function.

rand_direction
^^^^^^^^^^^^^^^^

This has been switched over to a list that allows for random choice.  It uses the same mechanism as 
the :doc:`Enemy Drops</godot/RPG/template/4-enemy-drops>` algorithm, although it has been simplified 
as we do not need our choice to be weighted.

.. code-block:: gdscript

    static func rand_direction(horizontal= true, vertical = true, diagonal = false):
        var dir_list = []
        if horizontal:
            dir_list.append(Vector2.LEFT)
            dir_list.append(Vector2.RIGHT)
        if vertical:
            dir_list.append(Vector2.UP)
            dir_list.append(Vector2.DOWN)
        if diagonal:
            dir_list.append(Vector2.LEFT + Vector2.UP)
            dir_list.append(Vector2.RIGHT + Vector2.UP)
            dir_list.append(Vector2.LEFT + Vector2.DOWN)
            dir_list.append(Vector2.RIGHT + Vector2.DOWN)
        
        # index is a number between 0 and list size - 1
        var index = randi() % dir_list.size()

        # load the Vector2
        return(dir_list[index])


loop_random_direction
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript 

    func loop_random_direction(horizontal= true, vertical = true, diagonal = false):	
        if movetimer > 0:
            movetimer -= 1
        if movetimer == 0 || is_on_wall():
            movedir = rand_direction(horizontal, vertical, diagonal)
            if movetimer_range and movetimer_range[1] > movetimer_range[0]:
                movetimer = randi() % (movetimer_range[1] - movetimer_range[0]) + movetimer_range[0]
            else:	
                movetimer = movetimer_length
