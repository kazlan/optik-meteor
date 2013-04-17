# Gestion del file uploader y de la carga del archivo de datos
# una vez cargado el archivo correctamente cambiar el boton a Importar 09/01/13
Template.fileUpload.rendered = ->  
  filepicker.constructWidget document.getElementById('uploadWidget')

Template.fileUpload.events
  'change #uploadWidget' : (event)->
    console.log "Upload done! ",event.fpfile.url
    Session.set "uploadedFileURL", event.fpfile.url
    $('#importActionDiv').html("Archivo subido a la nube.<p>URL: #{event.fpfile.url}</p>")
    $('#wizImport').removeClass('alert-info')
    $('#wizImport').addClass('alert-success')
    #testIO event.fpfile.url
  'click #btnCSV' : ->
    testIO Session.get "uploadedFileURL"
  'click #btnCLEAR' : ->
    Clientes.remove({}) 
  'click #btnBackup' : ->
    Meteor.call 'backupClientes', (err,result)->
      $('#backupActionDiv').html("Backup Ok. Se han guardado #{result} entradas.")
      $('#btnBackup').hide()
      $('#wizbackup').removeClass('alert-info')
      $('#wizbackup').addClass('alert-success')

  'click #btnRestore': ->
    Meteor.call 'restoreClientes'
  'click #btnFixCercanas' : ->
    fixAlertasCercanas()

Template.fileUpload.mensaje = ->
  return Session.get("mensaje") || ""

Meteor.startup ->
  filepicker.setKey 'A4fW2SAMPSGKQh6kXZcz6z'


#TestIO Saca por consola el contenido del archivo que hemos subido a filepicker.io
# archivo de ejemplo
# https://www.filepicker.io/api/file/c1xiyw0tSNau2Kt2CMww
testIO= (url) ->
  if url
    filepicker.read url, (data)->
      Meteor.call 'importar', data
  else
    flashKO "Error al importar el archivo desde Filepicker"