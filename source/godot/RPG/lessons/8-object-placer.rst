Godot Lesson 8: Object Placer
=======================================

Summary
--------

This lesson uses a tilemap to place enemies that are then spawned at run-time.
This can be used for keys, and other non-unique items as well.  It is no good
for things like signs that want individualized.  The lesson also makes use of mask and 
collision bits to keep the enemies from walking off screen.

Prerequisites
--------------

* An enemy or something to place (Lesson 3)
* Everything will make more sense with Lessons 1 through 7

Video
--------

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/uSQLV-Ju_QQ" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>



Code
--------

Repository: https://github.com/los-alamos-steam-lab/godot-tutorial/tree/8-enemy-placer


Enemy Tilemap Code
^^^^^^^^^^^^^^^^^^^
Major Changes from the Video:  

* To make this useful for other scenes (like keys) the final template code
  requires the tile name to be the full path to the scene (i.e enemies/stalfos).
  This change *has not been made here* but is made for the final template.


.. code-block:: gdscript

    extends TileMap

    # Called when the node enters the scene tree for the first time.
    func _ready():
        var size = get_cell_size()
        var offset = size/2
        for tile in get_used_cells():
            var name = get_tileset().tile_get_name(get_cell(tile.x, tile.y))
            var node = load(str("res://enemies/", name, ".tscn")).instance()
            node.global_position = tile * size + offset
            get_parent().call_deferred("add_child", node)
        queue_free()

