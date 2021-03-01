Godot Lesson 10: Heart UI
=======================================

Summary
--------

This adds player health to the HUD.  It allows for as many rows and columns of hearts as 
desired and gives granularity of 1/4 heart.

Prerequisites
--------------

* None - This is standalone

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/F_5BrQzIUdc" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Resources
-----------

* Heart Sprite: https://sprites.retro-dragon.com/index.php/2018/09/01/zlg-hearts/

Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/10-heart-ui


HUD Code
^^^^^^^^^^^^^^^^^^^
Major Changes from the Video:  

* Created func new_heart() instead of setting everything in _ready().  This allows
  for easier MAX_HEALTH increase.  Set the position in this code as well, instead 
  of in _physics_process.
    
.. code-block:: gdscript

    extends CanvasLayer

    onready var player = get_node("../player")

    # Number of hearts in a row
    const HEART_ROW_SIZE = 8

    # space between hearts (including heart width)
    const HEART_OFFSET = 8

    func _ready():
        for i in player.MAXHEALTH:
            new_heart()		

    # Called every frame. 'delta' is the elapsed time since the previous frame.
    func _process(delta):
        # find the heart that might not be full.
        var last_heart = floor(player.health)
        
        for heart in $hearts.get_children():
            var index = heart.get_index()
            
            # if this heart comes after the last heart, then it is empty
            # if this hear is the last heart, find the fraction
            # if this heart comes before the last heart, it is full
            if index > last_heart:
                heart.frame = 0
            elif index == last_heart:
                heart.frame = (player.health - last_heart) * 4
            elif index < last_heart:
                heart.frame = 4
                
        # update the sprite frame to be the player keys
        $keys.frame = player.keys

    # I pulled this out into a separate function and combined positioning, 
    # that way you can call it when increasing maxhealth
    func new_heart():
        var newheart = Sprite.new()
        newheart.texture = $hearts.texture
        newheart.hframes = $hearts.hframes
        $hearts.add_child(newheart)
        var index = newheart.get_index()
        var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
        # I explicitly state the floor hear to make the code more readable.
        # Origingal code was relying on integer division
        var y = floor(index / HEART_ROW_SIZE) * HEART_OFFSET
        newheart.position = Vector2(x, y)
