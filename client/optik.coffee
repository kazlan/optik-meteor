Clientes = new Meteor.Collection 'clientes'

#Lista de clientes para la tabla principal
Template.rowsClientes.clientes = ->
  data = Session.get "searchData"
  logProperties data
  if _.keys(data).length > 0
    return Clientes.find data
  else
    return false

#Eventos en las casillas de busqueda
Template.busquedas.events
  'keyup .qCampo, change .qCheck' : ->
    query = {}
    if (x = $("#qNombre").val()) != "" then query.nombre = {$regex: x.toUpperCase()}
    if (x = $("#qCiudad").val()) != "" then query.ciudad = {$regex: x.toUpperCase()}
    if (x = $("#qCP").val()) != "" then query.cp = {$regex: x}
    if $('#qCitas').is(':checked') then query.citas = {$exists: true}
    if $('#qAlertas').is(':checked') then query.alertas = {$exists: true}
    Session.set "searchData", query


  'click #btnCSV' : ->
    Meteor.call 'importar', 'datos.csv'
    console.log "csv click"
  'click #btnCLEAR' : ->
    Clientes.remove({})  

#Para cada linea de la tabla principal
Template.lineaCliente.countcitas = ->
  if (x=Clientes.findOne(@_id).citas)? then x.length
Template.lineaCliente.countalertas = ->
  if (x=Clientes.findOne(@_id).alertas)? then x.length
Template.lineaCliente.beauty_nombre = ->
  return @nombre.slice 0,24
Template.lineaCliente.beauty_ciudad = ->
  return @ciudad
Template.lineaCliente.events
  'click .eliminaCliente' : ->
    eliminar(@_id)

Meteor.startup ->
  Session.set "searchData", conCitasoAlertas()


##########################
# Helpers

# consoleLogs all properties of an object
logProperties = (obj) ->
  for key, value of obj
    console.log "#{key}:#{value}"

conCitasoAlertas = ->
  return {$or: [{citas: {$exists:true }},{alertas: {$exists: true}}]}