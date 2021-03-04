Godot Template: Item Class
================================================

Overview 
----------

Items are created independent of the Player, so that they can also be used by
enemies and other entities. Items are instanced and made children of the entity 
in Entity.use_item() (more detail in the :doc:`Entity Class<3-entity>`)

Scene Tree
--------------------

Item is a class and not a scene, but it relies on its instances having this tree structure.
Names not in quotes should not be changed.

* "Name" is type Item
    * [optional] AnimationPlayer is type AnimationPlayer
    * Sprite is type Sprite 
    * Hitbox is type Area2D
        * CollisionShape2D is type CollisionShape2D

Exports
----------

* DAMAGE
    * The amount the item harms an entity of a different type
* MAX_AMOUNT
    * The maximum number of the item that a single entity can have spawned at a time
* delete_on_hit
    * Signals whether the item should be deleted when it hits an entity of a different type
  

Code 
--------

The code is very basic on this and simply sets up the exports, assigns the item the same
TYPE as its parent and puts it in the item group.

item.gd 
^^^^^^^^^^^^

.. code-block:: gdscript

    var TYPE = null

    # input is set in entity.use_item()
    var input = null

    # These are settable in the inspector
    # (float, min, max, interval)
    export(float, 0, 20, 0.5) var		DAMAGE 			= 0.5
    export(int, 1, 20) var 			MAX_AMOUNT 		= 1
    export(bool) var 				delete_on_hit 	= false

    func _ready():
        TYPE = get_parent().TYPE
        add_to_group("item")
        