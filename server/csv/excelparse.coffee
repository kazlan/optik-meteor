
Meteor.methods
  importar: (archivo) ->
  #export de Google docs a TXT (Tab separated values)  
    importarCSV('datos.tsv')

importarCSV = (archivo)->
  fs = __meteor_bootstrap__.require('fs')
  path = __meteor_bootstrap__.require('path')
  base = path.resolve('.')
  buffer = fs.readFileSync( path.join(base, '/public/data/', archivo)).toString()
  data = buffer.split '\n'
  
  #parsea cada linea menos la primera
  linea2obj(linea) for linea in data[1..200]
  
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
  doc = 
    nombre : data[1].toString()
    provincia : data[17]
    direccion : data[18]
    ciudad : cortaCiudad data[19]#elimina las provincias entre ()
    cp : data[20].toString()
    telefono : data[21]
    marcas :
      marca : data[5]
      pup : data[15]
      fup : data[16]
    #citas y alertas solo las metemos si existen
    #citas: []
    #alertas: []

  if (x=Clientes.findOne({nombre:doc.nombre}))
    console.log "#{doc.nombre} ya existe"
  else  
    Clientes.insert doc

cortaCiudad = (str) ->
  if str.indexOf('(')?
    return str.slice 0, (str.indexOf '(')
  else
    return str
