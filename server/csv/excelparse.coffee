Backup = new Meteor.Collection 'backup'
Config = new Meteor.Collection 'config'

Meteor.methods
  importar: (data) ->
  #export de Google docs a TXT (Tab separated values)  
    importarFilePicker data

  backupClientes: ->
    console.log "backup iniciado"
    bulkClientes = Clientes.find({})
    countClientes = bulkClientes.count()
    console.log "Guardando ", countClientes, " entradas."
    Backup.remove({})
    bulkClientes.forEach (entrada)->
      delete entrada._id
      Backup.insert entrada
    console.log "Guardados", Backup.find({}).count(), "entradas."  

  restoreClientes: ->
    console.log "backup iniciado"
    bulkClientes = Backup.find({})
    countClientes = bulkClientes.count()
    console.log "restaurando ", countClientes, " entradas."
    Clientes.remove({})
    bulkClientes.forEach (entrada)->
      delete entrada._id
      Clientes.insert entrada
    console.log "Restauradas", Clientes.find({}).count(), "entradas."  

importarFilePicker = (buffer)->
  data = buffer.split '\n'
  #parsea cada linea menos la primera
  columnas = Config.findOne({})
  linea2obj(linea) for linea in data[1...]

########
# Estructura de linea
#-----------------------------------------------------------
# 0: Nombre grupo 1: Nombre 2:Cod. Fact 3:Cod 4:FAM 5: Marca
# 6: Pdte 05.05 7: Fact a abr12 8: Fact a abr11 9: FC NT abr12
# 10: FC NT abr11 11: Ped a abr12 12:Ped a abr11 13: Fact_tot 2011 14:Fact_tot 2010
# 15: Pzas último pedido 16: Fecha últ. Ped. 
# 17: Provincia 18: Dirección 19: Localidad 20: CP 21: Tel
################
linea2obj= (line)->

  data = line.split '\t'
  return if data[1].toString() == "" #Si no hay nombre en la linea nos la saltamos
  console.log "# ",data[6], data[16], data[17]
  doc = 
    nombre : data[1].toString()
    provincia : data[18]
    direccion : data[19]
    ciudad : cortaCiudad data[20]#elimina las provincias entre ()
    cp : data[21].toString() # 13/01/2013  Atento, en archivo anual no existe columna de CP
    telefono : data[21]
    marcas :[
      marca : data[6]
      pup : data[16]  #piezas ultimo pedido
      fup : data[17]  #facturado ultimo pedido
      pendientes: data[7]
      fact2012: data[8] #facturado 2012 !!!Cambiará de columna en el siguiente archivo
      ]

  if (x=Clientes.findOne({nombre:doc.nombre}))
    console.log "#{doc.nombre} ya existe", data[16], data[17]
    if data[16] and data[17] 
    #si la entrada de la marca tiene piezas facturadas se añaden
    #db.items.update( {}, { $pull : { r : {"_id": ObjectId("4e39519d5e746bc00f000000")} } }, false, false ) 
    #Eliminamos la entrda antigua de la marca
      Clientes.update({nombre: doc.nombre},{$pull: {marcas: { marca: data[6]}}},false,false)
    #insertamos los nuevos datos de la marca 
      Clientes.update({nombre: doc.nombre},{$push : {marcas: { marca: data[6],pup: data[16], fup: data[17], pendientes: data[7], fact2012: data[8]}}})
      console.log ">>> Pushed:" + data[6]
      Clientes.save
  else  
    Clientes.insert doc

cortaCiudad = (str) ->
  if str.indexOf('(') != -1
    return str.slice 0, (str.indexOf '(')
  else
    return str

