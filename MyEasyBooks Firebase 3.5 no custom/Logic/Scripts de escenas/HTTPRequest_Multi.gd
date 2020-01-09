extends HTTPRequest
var temp_body
var temp


func get_document_storage (path : String ) -> void:
	###### UNA PETICION AL SERVIDOR SIMPLE ###### 
	var url := Firestorage.STORAGE_URL + path
	print(url)
	request (url, Firestorage._get_requested_headers(), false, HTTPClient.METHOD_GET )

func _on_HTTPRequest_Multi_request_completed(result, response_code, headers, body):
	###### ESTO SIRVE PARA GUARDAR LA RESPUESTA DEL SERVIDOR EN UNA VARIABLE QUE PEUDE SER ACCEDIDA POR OTROS NODOS #######
	var temp_result = result
	var temp_response_code = response_code
	var temp_headers = headers
	temp_body = body ###### LO DEJO FUERA DEL ARRAY PARA SER USADO MAS FACIL
	temp = [temp_result, temp_response_code, temp_headers]
