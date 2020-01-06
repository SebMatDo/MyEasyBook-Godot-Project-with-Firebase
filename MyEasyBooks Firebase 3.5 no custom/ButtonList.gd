extends Button

var ar_number : int
var creator


func _on_ButtonList_button_down():
	creator.temp_ar=ar_number
	creator.charge_book()
