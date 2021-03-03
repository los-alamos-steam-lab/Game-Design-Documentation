Godot Template: Entity Class
================================================

Overview 
----------

The entity class is used for players, enemies, and eventual NPCs.  It covers movements, damage, 
health, etc.

Scene Tree 
-------------

Entity is a class and not a scene, but it relies on its instances having this tree structure.
Anything not in quotes should be named exactly.

* "Name" is type Entity
    * AnimationPlayer is type AnimationPlayer
    * Sprite is type Sprite 
    * CollisionShape2D is type CollisionShape2D
    * Hitbox is type Area2D
        * CollisionShape2D is type CollisionShape2D
        * [optional] RayCast2D is type RayCast2D


Exports
----------

* TYPE
    * Currently can be "ENEMY" and "PLAYER".  "NPC" is another likely class, for talking to villagers.
* HURT_SOUND
    * Link to a wav file.
* MAX_HEALTH
    * Default is 1, can range between 0.5 and 20 and is incremental by 0.5
* SPEED 
    * How fast the entity moves on the screen
* DAMAGE
    * The amount the entity harms an entity of a different type
* ITEM_DROP_PERCENT
    * The chance of an enemy dropping something when they die 
* ITEM_DROP_WEIGHT
    * Dictionary: the key is the scene path (-.tscn) to a pickup and the value is the weight of the pickup
    * This is covered more in :doc:`4-enemy-drops`

_ready()
-----------

* Set textures.
* Set health to MAX_HEALTH.
* Set home_position (this tells the entity where to respawn on reset.)
* Normalize the drop weights (drops are discussed in greater detail in :doc:`4-enemy-drops`
* Connect the camera signals (discussed in :doc:`1-camera`) 

Loops
---------

Movement
^^^^^^^^^^^

This loop is quite simple.  It grabs the entities movedir and normalizes it.  Then if it is in hitstun
it multiplies it my the hitstun multiplier.  Otherwise it multiplies it by speed.  Finally, it calls 
move_and_slide() to move the entity.

Damage 
^^^^^^^^

This loop updates hitstun, kills enemies with no health, and checks collisions to see if they cause damage.

* Make sure health isn't too high.  This could happen when player picks up a heart when only missing 1/4 heart.
* If in hitstun, reduce by 1 and set texture to hurt.
* Otherwise set the texture to default and check to see if the enemy is dead.
    * If the enemy is dead, trigger enemy death.
* Look for all areas that overlap the Entity hitbox.
    * Get the parent (body).
    * If the entity isn't in hitstun and the body has damage and the damage is greater than 0 and it isn't the same type as the entity:
        * Reduce health by damage 
        * Set hitstun and knockdir
        * Play the hurt sound
        * If the body has delete_on_hit set, then delete it (i.e. arrows)

Sprite Dir 
^^^^^^^^^^^^

This loop is also quite simple.  It sets the spritedir based on the movedir and calls anim_switch().
Entities with very simple animations will not call this loop.

Use item
-----------

Items are generally weapons. This function:

* Instances an item 
* Puts it in group "itemname" + "enitityid" so it can track the number of items owned by the entity.
* Adds the item as a child of the entity. The item sets its type to be the same as its parent in _ready() 
* If there are to many items instanced, then delete it.  This is determined my the item's MAX_AMOUNT, so it can't be determined before instancing.
* Set the item's input.  This is used by things like the sword scene that want to check to see if it is being held.
* Call the item's start() function.  This may include animation and sound effects.

  
Code 
--------

entity.gd 
^^^^^^^^^^^^

.. code-block:: gdscript

    extends KinematicBody2D

    class_name Entity

    # ATTRIBUTES
    # These are settable in the inspector
    export(String, "ENEMY", "PLAYER")	var TYPE 		= "ENEMY"
    export(String, FILE) 			var HURT_SOUND 	= "res://enemies/enemy_hurt.wav"

    # STATS
    # (float, min, max, increment)
    export(float, 0.5, 20, 0.5) 		var MAX_HEALTH 	= 1
    export(int) 						var SPEED 		= 70
    export(float, 0, 20, 0.5) 		var DAMAGE 		= 0.5


    # ITEM DROPS
    export(int, 0, 100, 5) 			var ITEM_DROP_PERCENT 		= 25

    # Keys are scene path names and values should be integers
    export(Dictionary) 				var ITEM_DROP_WEIGHTS = {
        'pickups/heart'	: 1,
        'pickups/key'	: 0,
    }


    # MOVEMENT
    var movedir := Vector2.ZERO
    var knockdir := Vector2.ZERO
    var spritedir := "Down"

    # COMBAT
    var health : float = MAX_HEALTH
    var hitstun := 0
    var state := "default"
    var home_position := Vector2.ZERO

    # TEXTURES
    var texture_default = null
    var texture_hurt = null

    # These get loaded a moment after the entity
    onready var anim := $AnimationPlayer
    onready var sprite := $Sprite
    onready var hitbox := $Hitbox
    onready var camera := get_node("/root/Main/Camera")

    func _ready():
        texture_default = sprite.texture
        texture_hurt = load(sprite.texture.get_path().replace(".png","_hurt.png"))
        add_to_group("entity")
        health = MAX_HEALTH
        home_position = position
        
        normalize_item_drop_weights()
        
        # the camera sends these signals
        camera.connect("screen_change_started", self, "screen_change_started")
        camera.connect("screen_change_completed", self, "screen_change_completed")

    func loop_movement():
        var motion
        if hitstun == 0:
            motion = movedir.normalized() * SPEED
        else:
            motion = knockdir.normalized() * 125
        move_and_slide(motion)

    func loop_spritedir():
        match movedir:
            Vector2.LEFT:
                spritedir = "Left"
            Vector2.RIGHT:
                spritedir = "Right"
            Vector2.UP:
                spritedir = "Up"
            Vector2.DOWN:
                spritedir = "Down"
        # This is a unary if statement.  sprite.flip_h is  set to the 
        # return of spritedir == "Left" (true or false)
        # This lets us not need separate anims for left and right
        sprite.flip_h = spritedir == "Left"

    func loop_damage():
        health = min(health, MAX_HEALTH)
        
        if hitstun > 0:
            hitstun -= 1
            sprite.texture = texture_hurt
        else:
            sprite.texture = texture_default
            if TYPE == "ENEMY" && health <= 0:
                enemy_death()
        
        for area in hitbox.get_overlapping_areas():
            var body = area.get_parent()
            
            # if the entity isn't in hitstun, and the overlapping body gives damage
            # and the overlapping body is of a different type
            if hitstun == 0 && body.get("DAMAGE") && body.get("DAMAGE") > 0 && body.get("TYPE") != TYPE:
                health -= body.DAMAGE
                hitstun = 10
                knockdir = global_position - body.global_position
                sfx.play(load(HURT_SOUND))
                
                if body.get("delete_on_hit") == true:
                    body.delete()

    func anim_switch(animation):
        var newanim = str(animation,spritedir)
        
        # if sprite dir is Left or Right
        if spritedir in ["Left","Right"]:
            newanim = str(animation,"Side")
        if anim.current_animation != newanim:
            anim.play(newanim)

    func use_item(item, input):
        var newitem = item.instance()
        var itemgroup = str(item,self)
        newitem.add_to_group(itemgroup)
        add_child(newitem)
        if get_tree().get_nodes_in_group(itemgroup).size() > newitem.MAX_AMOUNT:
            newitem.queue_free()
            return
        newitem.input = input
        newitem.start()

    func instance_scene(scene):
        var new_scene = scene.instance()
        new_scene.global_position = global_position
        get_parent().add_child(new_scene)

    func enemy_death():
        instance_scene(preload("res://enemies/enemy_death.tscn"))
        enemy_drop()
        queue_free()

    # When the enemy dies it may drop an item
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

    func screen_change_started():
        set_physics_process(false)
        
        # if the entity is an entity and no longer on camera then reset it
        if TYPE == "ENEMY":
            if !camera.camera_rect.has_point(position):
                reset()

    func screen_change_completed():
        set_physics_process(true)
        
        # If the entity is an enemy and not on camera don't run physics_process
        if TYPE == "ENEMY":
            if !camera.camera_rect.has_point(position):
                set_physics_process(false)

    # creates a new identical entity with it's original position
    # deletes the current entity
    # this also resets health
    func reset():
        var new_instance = load(filename).instance()
        get_parent().add_child(new_instance)
        new_instance.position = home_position
        new_instance.home_position = home_position
        new_instance.set_physics_process(false)
        queue_free()

    # With the way we handle item drops, we don't want to have the total 
    # number get too big.  This keeps it below or around 100.
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


    # put into helper script pls
    static func rand_direction():
        var new_direction = randi() % 4
        match new_direction:
            0:
                return Vector2.LEFT
            1:
                return Vector2.RIGHT
            2:
                return Vector2.UP
            3:
                return Vector2.DOWN

