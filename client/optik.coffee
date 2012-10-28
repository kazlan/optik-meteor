Clientes = new Meteor.Collection 'clientes'

Template.listaClientes.clientes = ->
  data = Session.get "searchData" 
  Clientes.find data 

Template.listaClientes.events 
  'click .listItem' : ->
    console.log "item clicked"
    insertar {nombre: "test"}
Template.listaClientes.rendered = ->
  $('#listaClientes').gridalicious()

#devuelve citas y alertas si existen
Template.cadaCliente.countcitas = ->
  if (x=Clientes.findOne(@_id).citas)? then x.length

Template.cadaCliente.countalertas = ->
  if (x=Clientes.findOne(@_id).alertas)? then x.length

Template.cadaCliente.events
  'click .eliminaCliente' : ->
    eliminar(@_id)

Template.searchPane.events
  'click #btnToList, keyup .qCampo' : ->
    query = {}
    #asigna los campos a query si no son blancos
    if (x = $("#qNombre").val()) != "" then query.nombre = {$regex: x}
    if (x = $("#qCiudad").val()) != "" then query.ciudad = {$regex: x}
    if (x = $("#qProvincia").val()) != "" then query.provincia = {$regex: x}
    if (x = $("#qCP").val()) != "" then query.cp = {$regex: x}
    if (x = $("#qTelefono").val()) != "" then query.telefono = {$regex: x}
    Session.set "searchData", query
  'click #btnCSV' : ->
    Meteor.call 'importar', 'datos.csv'
    console.log "csv click"
  'click #btnCLEAR' : ->
    Clientes.remove({})

Meteor.startup ->
  Session.set "searchData", conCitasoAlertas()


##########################
# Helpers

# consoleLogs all properties of an object
logProperties = (obj) ->
  for key, value of obj
    console.log "#{key}:#{value}"

conCitasoAlertas = ->
  #return {$or: [{citas: {$exists:true }},{alertas: {$exists: true}}]}
  return {alertas: {$exists: true}}