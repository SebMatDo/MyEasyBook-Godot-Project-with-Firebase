extends Control

###### SE INICIALIZAN LAS VARIABLES 
var img_name ## EL NOMBRE DE LA IMAGEN
var image_selected= false ## SI YA SE SELECCIONO UNA IMAGEN
var never_hide=false ## SI SE DEBE MANTENER ABIERTO EL POP UP
var pool_up ## PARA GUARDAR LA INFO DE LA IMAGEN EN BYTES
var image_data ## LOS DATOS DE LA IMAGEN
var imdir = OS.get_system_dir(0) ## DIRECCION DEL POP UP
var datos := { ### LOS DATOS QUE SE VAN A GUARDAR AL SUBIR EL LIBRO, SEGUN ESTANDARES DE FIREBASE 
	"nombre" : {},
	"autor" : {},
	"genero" : {},
	"info" : {},
	"correo" : {},
	"celular" : {},
	"creador" : {},
	"imagen" : {}
} 
var numID = "Book" ## EL NUMERO DEL LIBRO QUE SERÁ ESTA SUBIDA
var cantidad = { ## PARA ACTUALIZAR LA CANTIDAD DE LIBROS
	"cantidad_actual" : {}
}
var i  =0
var body 
func _on_B_Selectimage_button_down():
	## AL DARLE AL BOTON DE SELECCIONAR IMAGEN, SE ABRE EL POP UP PARA SELECCIONAR EL ARCHIVO ####
	$Selec_book_dialog.visible=true
	$Selec_book_dialog.set_current_path(imdir)
	$Selec_book_dialog.set_current_dir(imdir)
	$Selec_book_dialog.set_show_hidden_files(true)
	never_hide=true

func _on_B_finish_button_down():
	
	#### SI ALGUN CAMPO NO ESTA LLENO NO DEJARA SUBIR EL LIBRO #####
	if $L_nombre.text.empty() or $L_autor.text.empty() or $L_genero.text.empty() or $L_info.text.empty() or image_selected == false:
		$Label.text= " Por favor rellene todos los campos "
		return  
	######## SE CONECTA AL HOST CADA VEZ QUE SE QUIERE HACER UNA PETICION ####
	if Firestorage.conectado == false:
		$Label.text = "Conectando... "
		yield(get_tree().create_timer(0.1),"timeout")
		Firestorage.con()
	#### SUBIR LA IMAGEN A FIRESTORAGE ##########################
	var error = Firestorage.save_document_storage(img_name,pool_up)
	$Label.text="Subiendo Imagen"
	while Firestorage.upload_end==false:
		pass
	####### SI LA IMAGEN SE SUBE BIEN, SEGUIRA SUBIENDO LOS OTROS DATOS ###
	if error==0:
		$Label.text="Subiendo datos"
	
	### SI NO, DIRÁ CUAL ES EL ERROR, LOS PRINT SON SOLO DEBUG #####
	else:
		$Label.text="Error # %s por favor, intente después" % error
		print("ESTATUS: ", Firestorage.httpc.get_status())
		
		print ("BODY LENGHT: ", Firestorage.httpc.get_response_body_length())
		print ( "Response Code: ",Firestorage.httpc.get_response_code ( ))
		print (Firestorage.httpc.get_response_headers_as_dictionary ( ))
		Firestorage.httpc.set_read_chunk_size ( 2000 )
		body = Firestorage.httpc.read_response_body_chunk()
		print(len(body))
		print(to_json(body.get_string_from_utf8()))
		Firestorage.httpc.poll()
		print ("HAS RESPONSE : ", Firestorage.httpc.has_response())
		return
	########### SE LLENA EL DICCIONARIO CON LOS DATOS DEL USUARIO #####
	datos.nombre = { "stringValue": $L_nombre.text }
	datos.autor = { "stringValue": $L_autor.text }
	datos.genero = { "stringValue": $L_genero.text }
	datos.info = { "stringValue": $L_info.text }
	
	############# SE LLENAN CON LOS DATOS DE CONTACTO DEL AUTOR DEL LIBRO ####
	datos.celular = { "stringValue" : Firebase.Omega.user_info["fields"]["numero1"]["stringValue"]}
	datos.correo = { "stringValue" : Firebase.Omega.user_info["fields"]["correo"]["stringValue"]}
	datos.creador = { "stringValue" : Firebase.Omega.user_info["fields"]["nombre"]["stringValue"] + Firebase.Omega.user_info["fields"]["apellido"]["stringValue"]}
	
	###### SE SUBE A UN DICCIONARIO LOS DATOS DE LA IMAGEN ####
	datos.imagen = { "stringValue" : image_data }
	
	######## SE GUARDA EL DOCUMENTO Y SE ESPERA LA RESPUESTA #####
	Firebase.save_document ("Books?documentId=%s" % numID , datos)
	Firebase.Omega.loading()
	yield(Firebase.http,"request_completed")
	
	###### SE ACTUALIZA LA CANTIDAD DE LIBROS PUBLICADOS #######
	cantidad.cantidad_actual = { "integerValue": (int(get_parent().get_parent().actual)+1) }
	Firebase.update_document("Cantidad/cantidad_actual", cantidad)
	Firebase.Omega.loading()
	$Label.text="Subiendo"
	yield(Firebase.http,"request_completed")
	$Label.text="Subida exitosa"
	yield(get_tree().create_timer(0.5),"timeout")
	Firebase.Omega.change_room("res://Logic/Escenas/explor.tscn")

func _on_L_info_text_changed(new_text):
	## cuando se escribe en la linea invisible se muestra en la label ##
	$LB_info.text=new_text

func _on_Selec_book_dialog_file_selected(path):
	### Al seleccionarse un archivo imagen se hace lo siguiente ###
	image_selected=true
	never_hide=false
	### Se dice que ya selecciono algo y se cierra el pop up####
	print("file")
	
	#### Esta parte se encarga de mostrar la imagen en pantalla ####
	var img= Image.new()
	var image_texture = ImageTexture.new()
	img.load(path)
	img.resize(512,512,Image.INTERPOLATE_BILINEAR) ## disminuimos el tamaño de la imagen para que no pese tanto
	pool_up = img.get_data()
	
	image_texture.create_from_image(img)
	$TextureRect.texture = image_texture
	$TextureRect.set_size(Vector2(90,110))
	
	############ Luego procedemos a sacar el pool array bytes. ##### 
	# más los datos para reconstruir ##
	
	img_name = numID+"image"
	image_data = img_name+","+ "%s" % img.get_width()  + "," +"%s" % img.get_height() +"," +"%s" % img.get_format() # 0 = nombre, 1= width, 2 =height, 3=format
	image_data=str(image_data)
	print(image_data)

func _process(delta):
	####### Esto tambien es para seleccionar la imagen en android, ya que un bug no deja abrir las carpetas ######
	if never_hide == true:
		$B_Selectimage.visible=false
		$B_finish.visible=false
		$Selec_book_dialog.visible=true
		get_parent().get_node("B_cancel").visible=false
	else:
		$B_Selectimage.visible=true
		$B_finish.visible=true
		get_parent().get_node("B_cancel").visible=true

func _on_B_CANCEL_button_down():
	## Al darle al boton cancel se puede cerrar el pop up, esto se hace por el bug de godot ###
	never_hide=false
	$Selec_book_dialog.visible=false
	print("cancelado")

func _on_Selec_book_dialog_dir_selected(dir):
	## al seleccionar un folder se abre esa ruta ##
	imdir=dir
	$Selec_book_dialog.set_current_path(imdir)
	$Selec_book_dialog.set_current_dir(imdir)
	
	print("folder")

	
	


func _on_B_os_button_down():
	if i<7:
		imdir = OS.get_system_dir(i)
	
	if i>7:
		i=0
		imdir="/storage/emulated/0/DCIM/Camera"
		
	$Selec_book_dialog.set_current_path(imdir)
	$Selec_book_dialog.set_current_dir(imdir)
	$Selec_book_dialog.set_show_hidden_files(true)
	i+=1
