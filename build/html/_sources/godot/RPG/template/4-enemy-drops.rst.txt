Godot Template: Enemy Drops
================================================

Overview 
----------

This bit of code determines what enemies drop and how often they drop it.  
It would be a good template for NPC conversations as well.

Exports
---------

* ITEM_DROP_PERCENT
    * The chance of an enemy dropping something when they die 
    * This is a percent and should be from 0-100
* ITEM_DROP_WEIGHT
    * Dictionary: the key is the scene path (-.tscn) to a pickup and the value is the weight of the pickup
    * Weights are not percentages, but simply relative to each other.  An item with weight 4 has twice the likelihood of dropping as an item of weight 2.

Normalization
---------------

Because items are randomly chosen by adding them to a list and picking one, 
we need to make sure our list does not end up ridiculously long.  `Entity.normalize_item_drop_weights()`_ 
tries to keep the total item weight under 100 and is run during Entity._ready()

* Sum all of the weights
    * We cannot force a dictionary export to be an integer, so we need to round them.
    * This will fail if they are not at least numeric, we want it to.
* If the sum is greater than 100, then set our multiplier so that the sum would be 100.
* For each value:
    * Multiply it by the multiplier 
    * Round it, unless rounding it forces it to zero, in which case set it to 1.
* Because of the rounding, our sum may end up being greater than 100, that's not that important.
* If it is important that you preserve initial weights for future adjustment (i.e. if single 
  weights are adjusted in the code based on game-play) then you should make sure to do that somewhere.  
  This process destroys the original list.


Enemy Death 
-------------

When and entity of type EMEMY dies, it calls 'Entity.enemy_drop()'_. This function determines 
what, if anything, they drop and instances the drop scene.

* Get a random number between 0 and 99.
* If it is strictly less that the drop percentage, then move on.
* Go through all of the keys in ITEM_DROP_WEIGHTS.  Add `value` number of copies `key` into drop_list.
* Randomly select a key from drop_list and instance the scene.

  
Code 
--------

Entity.normalize_item_drop_weights() 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func normalize_item_drop_weights():
        var sum = 0
        # force multiplier to be a float
        var multiplier = 1.0
        for key in ITEM_DROP_WEIGHTS:
            sum += round(ITEM_DROP_WEIGHTS[key])
        # if our sum is greater than 100 then we want then find the 
        # multiplier that will bring it close to 100
        if sum > 100:
            multiplier = 100/sum
        
        for key in ITEM_DROP_WEIGHTS:
            # First do the multiplier
            ITEM_DROP_WEIGHTS[key] = multiplier * float(ITEM_DROP_WEIGHTS[key])
            # if rounding it will make it zero (i.e. it was .4) then make it 1
            if ITEM_DROP_WEIGHTS[key] > 0 && round(ITEM_DROP_WEIGHTS[key]) == 0:
                ITEM_DROP_WEIGHTS[key] = 1
            else:
                ITEM_DROP_WEIGHTS[key] = round(ITEM_DROP_WEIGHTS[key])
        
Code 
--------

Entity.enemy_drop() 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: gdscript

    func enemy_drop():
        # drop is a number between 0 and 99
        var drop = randi() % 100
        
        # if drop is strictly less than our percentage, then drop something
        if drop < ITEM_DROP_PERCENT:
            # Here we are basically filling a hat with names.
            # For each key, we'll put [value] entries of the key into the list
            var drop_list = []
            for key in ITEM_DROP_WEIGHTS:
                for i in range(ITEM_DROP_WEIGHTS[key]):
                    drop_list.append(key)
            
            # index is a number between 0 and list size - 1
            var index = randi() % drop_list.size()
            # load the scene at index
            var scene = str("res://", drop_list[index], ".tscn")
            instance_scene(load(scene))
