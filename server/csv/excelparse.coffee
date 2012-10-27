
Meteor.methods
  importar: (archivo) ->
    console.log "en metodo"
    importarCSV('datos.csv')

importarCSV = (archivo)->
  fs = __meteor_bootstrap__.require('fs')
  path = __meteor_bootstrap__.require('path')
  base = path.resolve('.')
  buffer = fs.readFileSync( path.join(base, '/public/data/', archivo)).toString()
  data = buffer.split '\n'
  
  #parsea cada linea menos la primera
  linea2obj(linea) for linea in data[1..3]
  
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

  data = line.split ','
  doc = 
    nombre : data[1]
    provincia : data[17]
    direccion : data[18]
    ciudad : data[19]
    cp : data[20]
    telefono : data[21]
    marcas :
      marca : data[5]
      pup : data[15]
      fup : data[16]
    citas : []
    alertas : []
  for key, value of doc
    console.log "#{key}:#{value}"
  Clientes.insert doc
