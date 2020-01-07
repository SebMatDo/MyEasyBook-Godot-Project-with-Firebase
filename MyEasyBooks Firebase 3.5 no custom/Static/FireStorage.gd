extends Node
######### INICIALIZAR VARIABLES ###########

const STORAGE_URL = "https://firebasestorage.googleapis.com/v0/b/myeasybookprueba.appspot.com/o"
const UPLOAD_URL = "?uploadType=media&name="
var httpc: HTTPClient
var http : HTTPRequest
var temp_body
var temp
var err = 0
const POSTING_URL="/v0/b/myeasybookprueba.appspot.com/o"
var STATUS
var upload_end=false
# [0] = result
# [1] = response_code
# [2] = headers
var conectado=false


func _ready():
	## INICIALIZAR HTTPS NODOS ####
	httpc=HTTPClient.new()
	http=HTTPRequest.new() 
	
	add_child(http)
	#################################
	
	###########CONECTAR HTTP REQUEST PARA QUE ME DIGA CUANDO ACABA##########
	http.connect("request_completed",self,"_on_HTTPRequest_request_completed")
	############## CONECTAR EL HTTP CLIENT ###############
	
func con():
	### CONECTAR A HOST ####
	err = httpc.connect_to_host("https://firebasestorage.googleapis.com",-1)
	assert(err == OK)
	while httpc.get_status() == HTTPClient.STATUS_CONNECTING or httpc.get_status() == HTTPClient.STATUS_RESOLVING:
		httpc.poll()
		print("Connecting...")
		OS.delay_msec(500)
	print("Connected")
	httpc.set_blocking_mode(true)
	conectado=true
	
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	###### ESTO SIRVE PARA GUARDAR LA RESPUESTA DEL SERVIDOR EN UNA VARIABLE QUE PEUDE SER ACCEDIDA POR OTROS NODOS #######
	var temp_result = result
	var temp_response_code = response_code
	var temp_headers = headers
	temp_body = body ###### LO DEJO FUERA DEL ARRAY PARA SER USADO MAS FACIL
	temp = [temp_result, temp_response_code, temp_headers]
	
func get_document_storage (path : String) -> void:
	###### UNA PETICION AL SERVIDOR SIMPLE ###### 
	var url := STORAGE_URL + path
	print(url)
	http.request (url, _get_requested_headers(), false, HTTPClient.METHOD_GET )
	
func save_document_storage( path : String, fields) :
	upload_end=false
	### PARA SUBIR LA IMAGEN AL FIRESTORAGE ####
	print("Saving")
	var url := POSTING_URL+ UPLOAD_URL + path ## LA URL DE REQUEST_RAW SE PIDE SIN LA PARTE DEL HOST, POR ESO LA URL CAMBIA
	var error = httpc.request_raw (httpc.METHOD_POST,url, _get_requested_headers(), fields)
	print(httpc.poll() , " ERR ", error )
	upload_end=true
	conectado=false
	return error
	
	
func _get_requested_headers():
	##### EL SERVIDOR DE FIREBASE PIDE UN POOL STRING ARRAY PARA LOS HEADERS Y ACA LE PASAMOS LA AUTORIZACION DE QUE EL USUARIO ESTA LOGEADO######
	return PoolStringArray ([
#		"Content-Type: image/png",
		"Authorization: Bearer %s" % Firebase.user_info.token
	])

func info_end():
	### Esto se hará al emitir la señal de que terminó la peticion para subir la imagen ####
	print ( " info ")

func _process(_delta):
	## intento de saber el status actual del cliente ##
	httpc.poll()
	if httpc.get_status() != STATUS:
		STATUS=httpc.get_status()
		print("STATUS" , STATUS)
