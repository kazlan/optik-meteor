Clientes = new Meteor.Collection "clientes"

Meteor.methods
  importar: (archivo) ->
    importarCSV('datos.csv')

importarCSV = (archivo)->
  fs = __meteor_bootstrap__.require('fs')
  path = __meteor_bootstrap__.require('path')
  base = path.resolve('.')
  buffer = fs.readFileSync( path.join(base, '/public/data/', archivo)).toString()
  data = buffer.split '\n'
  
  #parsea cada linea menos la primera
  linea2obj(linea) for linea in data[1...]

########
# Estructura de linea
# PREFERENTES,"PILAR ARANDA, OPTICA ARANDA BELLVER PILAR",006611,006611,,THF,13,18
#,0,880.00,0.00,31.00,0.00,,,4,2012-04-02,VALENCIA,"TROBAT, 24",XATIVA (VALENCIA)
#,46800,962274799
#-----------------------------------------------------------
# 0: Nombre grupo 1: Nombre 2:Cod. Fact 3:Cod 4:FAM 5: Marca
# 6: Pdte 05.05 7: Fact a abr12 8: Fact a abr11 9: FC NT abr12
# 10: FC NT abr11 11: Ped a abr12 12:Ped a abr11 13: Fact_tot 2011 14:Fact_tot 2010
# 15: Pzas último pedido 16: Fecha últ. Ped. 
# 17: Provincia 18: Dirección 19: Localidad 20: CP 21: Tel
linea2obj= (linea)->
  data = linea.split ','
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
  #test    
  for key, value in doc
    console.log "#{key}:#{value}"      

  #Clientes.insert(doc)
