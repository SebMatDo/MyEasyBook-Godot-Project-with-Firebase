extends FileDialog
func _ready():
	set_filters(PoolStringArray(["*.png ; PNG Images","*.jpg ; JPG Images", "*.jpeg ; JPG Images"]))
	if OS.get_name() == "Android":
		var V=$Node2D.get_position()
		V.x-=135
		$Node2D.set_position(V)

