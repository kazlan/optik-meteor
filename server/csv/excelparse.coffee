Backup = new Meteor.Collection 'backup'
Config = new Meteor.Collection 'config'

Meteor.methods
  importar: (data) ->
  #export de Google docs a TXT (Tab separated values) 
    datos = data.split '\n'
    #parsea cada linea menos la primera
    columnas = Config.findOne({})
    linea2obj(linea) for linea in datos[1...]

  backupClientes: ->
    bulkClientes = Clientes.find({})
    countClientes = bulkClientes.count()
    console.log "Guardando ", countClientes, " entradas."
    Backup.remove({})
    bulkClientes.forEach (entrada)->
      delete entrada._id
      Backup.insert entrada
    count = Backup.find({}).count()
    console.log "Guardados", count, "entradas."  
    return count

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

########
# Estructura de linea
#-----------------------------------------------------------
# 0: Nombre grupo 1: Nombre 2:Cod. Fact 3:Cod 4:FAM 5: Marca
# 6: Pdte 05.05 7: Fact a abr12 8: Fact a abr11 9: FC NT abr12
# 10: FC NT abr11 11: Ped a abr12 12:Ped a abr11 13: Fact_tot 2011 14:Fact_tot 2010
# 15: Pzas último pedido 16: Fecha últ. Ped. 
# 17: Provincia 18: Dirección 19: Localidad 20: CP 21: Tel
################
# Enero 2013
# 0: Nombre grupo 2: Nombre 4: Codigo 6:Cluster 7:marca 8:pdte
# 9: piezas fact 2013 15: fact total 2012 17:pup 18:fup
# 19 provincia 20: direccion 21: ciudad 22:cp 23: tlf
linea2obj= (line)->

  data = line.split '\t'
  datos =   #19/02/2013 cargando todo en datos puedo recoger el orden de las columnas
            # sin tocar el codigo que viene detrás
    nombre: data[2]
    codigo: data[4]
    cluster: data[5] #16/04/13 - Añadimos cluster a los datos necesarios
    marca: data[7]
    pendientes: data[8]
    fact2013: data[9]
    fact2012: data[15]
    pup: data[17]
    fup: data[18]
    provincia: data[19]
    direccion: data[20]
    ciudad: data[21]
    cp: data[22]
    tlf: data[23]

  return if datos.nombre.toString() == "" #Si no hay nombre en la linea nos la saltamos
  doc = 
    nombre : datos.nombre.toString()
    provincia : datos.provincia
    direccion : datos.direccion
    ciudad : cortaCiudad datos.ciudad#elimina las provincias entre ()
    cp : datos.cp.toString() # 13/01/2013  Atento, en archivo anual no existe columna de CP
    telefono : datos.telefono
    cluster : datos.cluster
    marcas :[
      marca : datos.marca
      pup : datos.pup  #piezas ultimo pedido
      fup : datos.fup  #facturado ultimo pedido
      pendientes: datos.pendientes
      fact2012: datos.fact2012 #facturado 2012 
      ]

  # Logica actual 13/02/2013
  # si el cliente no existe se añaden los datos a piñon
  # si ya existe me cargo sus datos de la marca y los refresco con los del doc nuevo
  if (x=Clientes.findOne({nombre:datos.nombre}))
    # 16/04/13 - Apaño para añadir el cluster a las fichas
    unless x.cluster
      Clientes.update({nombre: datos.nombre},{$set: {cluster: datos.cluster}})
      console.log "Added " + datos.cluster + " a " + datos.nombre
    if datos.fup and datos.pup 
    #si la entrada de la marca tiene piezas facturadas se añaden
    #db.items.update( {}, { $pull : { r : {"_id": ObjectId("4e39519d5e746bc00f000000")} } }, false, false ) 
    #Eliminamos la entrda antigua de la marca
      Clientes.update({nombre: datos.nombre},{$pull: {marcas: { marca: datos.marca}}},false,false)
    #insertamos los nuevos datos de la marca 
      Clientes.update({nombre: doc.nombre},{$push : {marcas: { marca: datos.marca,pup: datos.pup, fup: datos.fup, pendientes: datos.pendientes, fact2012: datos.fact2012}}})
      #console.log ">>> Pushed:" + datos.marca + " de " + datos.nombre
  else  
    Clientes.insert doc

cortaCiudad = (str) ->
  if str.indexOf('(') != -1
    return str.slice 0, (str.indexOf '(')
  else
    return str

