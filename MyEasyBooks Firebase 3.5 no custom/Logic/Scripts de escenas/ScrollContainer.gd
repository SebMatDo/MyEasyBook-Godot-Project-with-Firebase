extends ScrollContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var v
# Called when the node enters the scene tree for the first time.
func _ready():
	v = get_v_scrollbar()
	
	v.set_custom_step(100)
	v.min_value=351
