extends Control
var img_name
var image_selected= false
var never_hide=false
var pool_up
var image_data
var imdir = OS.get_system_dir(6)
var datos := {
	"nombre" : {},
	"autor" : {},
	"genero" : {},
	"info" : {},
	"correo" : {},
	"celular" : {},
	"creador" : {},
	"imagen" : {}
} 
var numID = "Book"
var cantidad = {
	"cantidad_actual" : {}
}

func _on_B_Selectimage_button_down():
	$Selec_book_dialog.visible=true
	$Selec_book_dialog.set_current_path(imdir)
	$Selec_book_dialog.set_current_dir(imdir)
	never_hide=true


func _on_B_finish_button_down():
	if $L_nombre.text.empty() or $L_autor.text.empty() or $L_genero.text.empty() or $L_info.text.empty() or image_selected == false:
		$Label.text= " Por favor rellene todos los campos "
		return  
	datos.nombre = { "stringValue": $L_nombre.text }
	datos.autor = { "stringValue": $L_autor.text }
	datos.genero = { "stringValue": $L_genero.text }
	datos.info = { "stringValue": $L_info.text }
	
	datos.celular = { "stringValue" : Firebase.Omega.user_info["fields"]["numero1"]["stringValue"]}
	
	datos.correo = { "stringValue" : Firebase.Omega.user_info["fields"]["correo"]["stringValue"]}
	
	datos.creador = { "stringValue" : Firebase.Omega.user_info["fields"]["nombre"]["stringValue"] + Firebase.Omega.user_info["fields"]["apellido"]["stringValue"]}
	
	datos.imagen = { "stringValue" : image_data }
	
	Firebase.save_document ("Books?documentId=%s" % numID , datos)
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	
	cantidad.cantidad_actual = { "integerValue": (int(get_parent().get_parent().actual)+1) }
	Firebase.update_document("Cantidad/cantidad_actual", cantidad)
	Firebase.Omega.loading()
	$Label.text="Subiendo"
	yield(Firebase.http,"request_completed")
	
	#### Subir el pool a firestorage ###
	
	Firestorage.save_document_storage(img_name,pool_up)
	
	while Firestorage.httpc.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		Firestorage.httpc.poll()
		$Label.text="Subiendo imagen"
	
	$Label.text="Subida completa"
	yield(get_tree().create_timer(0.5),"timeout")
	Firebase.Omega.change_room("res://Logic/Escenas/explor.tscn")
	
func _on_L_info_text_changed(new_text):
	$LB_info.text=new_text


func _on_Selec_book_dialog_file_selected(path):
	image_selected=true
	never_hide=false
	print("file")
	#### Esto se encarga de mostrar la imagen en pantalla ####
	var img= Image.new()
	var image_texture = ImageTexture.new()
	img.load(path)
	img.resize(256,256,Image.INTERPOLATE_BILINEAR) ## disminuimos el tamaño de la imagen para que no pese tanto
	pool_up = img.get_data()
	img.resize(90,110,Image.INTERPOLATE_BILINEAR) 
	image_texture.create_from_image(img)
	$TextureRect.texture = image_texture
	$TextureRect.set_size(Vector2(90,110))
	
	############ Luego procedemos a sacar el pool array bytes. ##### 
	# más los datos para reconstruir ##
	
	img_name = path.get_file()
	image_data = img_name+","+ "256" + "," +"256" +"," +"%s" % img.get_format() # 0 = nombre, 1= width, 2 =height, 3=format
	image_data=str(image_data)
	print(image_data)





func _on_Selec_book_dialog_dir_selected(dir):
	imdir=dir
	$Selec_book_dialog.set_current_path(imdir)
	$Selec_book_dialog.set_current_dir(imdir)
	
	print("folder")

	
	
	

func _process(delta):
	if never_hide == true:
		$Selec_book_dialog.visible=true



func _on_B_CANCEL_button_down():
	never_hide=false
	$Selec_book_dialog.visible=false
	print("cancelado")
