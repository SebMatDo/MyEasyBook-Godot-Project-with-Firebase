extends Control

var document ="/"+"ImagenPrueba.png"
const download = "?alt=media&token="
var pool
var image_path
var pool_up
var enc
func _ready():
	$FileDialog.visible=true

func _on_Button_button_down():
	document ="/"+"whitebc.png"
	init_donwload()
	


func _on_Button2_button_down():
	init_upload()

func init_donwload():
		
	Firestorage.get_document_storage(document)
	yield(Firestorage.http,"request_completed")
	var meta_info=parse_json(Firestorage.temp_body.get_string_from_ascii())
	var token= meta_info["downloadTokens"]
	var new_url = document + download + token
	Firestorage.get_document_storage(new_url)
	yield(Firestorage.http,"request_completed")
	pool = pool_up
	var image = Image.new()
	image.create_from_data(256,256,false,5,pool_up)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	$TextureRect.texture=texture
	texture.set_size_override($TextureRect.get_minimum_size())
	
func init_upload():
	
	
	#### Esto se encarga de mostrar la imagen en pantalla ####
	var img= Image.new()
	var image_texture = ImageTexture.new()
	img.load(image_path)
	img.resize(256,256,Image.INTERPOLATE_BILINEAR) ## disminuimos el tamaño de la imagen para qu neo pese tanto
	image_texture.create_from_image(img)
	$TextureRect.texture = image_texture
	############ Luego procedemos a sacar el pool array bytes. ##### 
	# más los datos para reconstruir ##
	pool_up = img.get_data()

	#### Subir el pool a firestorage ###
	
	Firestorage.save_document_storage("13-137597_free-open-book-book.png",pool_up)
	
	while Firestorage.httpc.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		Firestorage.httpc.poll()
		print("Subiendo...")
		OS.delay_msec(500)
	
	print("Subida completa")
	
	

func _on_FileDialog_file_selected(path):
	image_path=path
