extends FileDialog
func _ready():
	set_filters(PoolStringArray(["*.png ; PNG Images"]))
