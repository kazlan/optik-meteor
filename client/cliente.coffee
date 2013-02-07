#Funciones basicas contra la db
insertar= (cliente)->
	Clientes.insert(cliente)

eliminar= (id) ->
	Clientes.remove({_id: id}) 



