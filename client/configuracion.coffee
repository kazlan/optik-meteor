Config = new Meteor.Collection 'config'

Template.config.columnas = ->
	return Config.findOne {}

Meteor.startup ->
  if Config.find().count() == 0
    data = 
      pup: 16
      fup: 17
      marca: 6
      nombre: 1
      provincia: 18
      direccion: 19
      ciudad: 20
      cp: 21
      telefono: 21
      pendientes: 7
      fact2012: 8
    Config.insert(data)






