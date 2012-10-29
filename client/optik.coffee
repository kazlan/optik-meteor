Clientes = new Meteor.Collection 'clientes'
Archivos = new Meteor.Collection 'archivos'

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
    testIO "https://www.filepicker.io/api/file/c1xiyw0tSNau2Kt2CMww"
    console.log "csv click"
  'click #btnCLEAR' : ->
    Clientes.remove({})  

  #test de lectura de Filepicker.io
  'click #btnREAD' : ->
    testIO "https://www.filepicker.io/api/file/c1xiyw0tSNau2Kt2CMww"


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

#Gestión de la barra de navegación
Template.navigate.events
  'click #qDatos' : ->
    $('#qHome').removeClass 'active'
    $('#qDatos').addClass 'active'
    Session.set 'paginaActual', 'datos' 
  'click #qHome' : ->
    $('#qDatos').removeClass 'active'
    $('#qHome').addClass 'active'
    Session.set 'paginaActual', 'home'  
#
Template.pageRenderer.homePage = ->
  return Session.equals "paginaActual", "home"
Template.pageRenderer.datosPage = ->
  return Session.equals "paginaActual", "datos"

# Gestion del file uploader
Template.fileUpload.rendered = ->  
  filepicker.constructWidget document.getElementById('uploadWidget')
  console.log "fileupload rendered"
Template.fileUpload.events
  'change #uploadWidget' : (ev)->
    archivos.insert(url: ev.files[0].url, timeStamp: new Date())
    console.log "Subido archivo a " + ev.files[0].url

Meteor.startup ->
  Session.set "searchData", conCitasoAlertas()
  Session.set "paginaActual","home"
  filepicker.setKey 'A4fW2SAMPSGKQh6kXZcz6z'

##########################
# Helpers
#
#TestIO Saca por consola el contenido del archivo que hemos subido a filepicker.io
# archivo de ejemplo
# https://www.filepicker.io/api/file/c1xiyw0tSNau2Kt2CMww
testIO= (url) ->
  filepicker.read url, (data)->
    Meteor.call 'importar', data

# consoleLogs all properties of an object
logProperties = (obj) ->
  for key, value of obj
    console.log "#{key}:#{value}"

conCitasoAlertas = ->
  return {$or: [{citas: {$exists:true }},{alertas: {$exists: true}}]}