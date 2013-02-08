#Codigo a lanzar en cuanto se activa la app
console.log Session.get 'logOK'
Session.set 'logOK', false

Meteor.subscribe "userinfo"

Meteor.autosubscribe ->
  Meteor.subscribe "listaClientes", Session.get("searchData")
  
Clientes = new Meteor.Collection 'clientes'

#Flag para no refrescar toda la app y despues hacer el logout
Template.contenedor.logOK = ->
  console.log "en template", Session.get 'logOK'
  return Session.get 'logOK'

#Lista de clientes para la tabla principal
Template.rowsClientes.clientes = ->
  data = Session.get "searchData"

  if _.keys(data).length > 0
    return Clientes.find(data,{sort: {'alertaCercana': 1}})
  else
    return false

#Eventos en las casillas de busqueda
Template.busquedas.events
  'keyup .qCampo, change .qCheck' : ->
    query = {}
    if (x = $("#qNombre").val()) != "" then query.nombre = {$regex: x.toUpperCase()}
    if (x = $("#qCiudad").val()) != "" then query.ciudad = {$regex: x.toUpperCase()}
    if (x = $("#qProvincia").val()) != "" then query.provincia = {$regex: x.toUpperCase()}
    if $('#qAlertas').is(':checked') then query.alertas = {$exists: true}
    # Beta 18/01/13: Busca docs que tengan una fecha de ultimo pedido inferior a la que se ponga
    # mirar mas adelante de cambiar por un dropdown 'sin fecha/ult. 6 meses/ult. 3 meses/ todos'
    if (x = $('#qFecha').val()) != ""
      #fecha x meses atras de hoy
      fecha = moment().subtract('months',x).format("YYYY-MM-DD")
      query['marcas.fup'] = {$lte: fecha, $ne: ''}
    Session.set "searchData", query

  'click #qReset' : ->
    $('.qCampo').val("")
    Session.set "searchData", conNotasoAlertas()

Template.rowsClientes.rendered=->
  $('#datetimepicker').datetimepicker({
    language: 'es', autoclose: true, minview: 1,
    todayHighlight: true, weekStart: 1,minuteStep:15})

#Para cada linea de la tabla principal
Template.lineaCliente.countcitas = ->
  if (x=Clientes.findOne(@_id).citas)? then x.length
Template.lineaCliente.countalertas = ->
  if (x=Clientes.findOne(@_id).alertas)? then x.length
Template.lineaCliente.alertaActiva = ->
  return @estado == "activa"
Template.lineaCliente.momentPedido = ->
  return moment(@fup,"YYYY-MM-DD").fromNow()
Template.lineaCliente.moment = ->
  return moment(@fecha,"DD-MM-YYYY HH:mm:ss").fromNow()

Template.lineaCliente.events
  'click #spanNombreCliente' : ->
    Session.set 'paginaActual', 'detalleCliente'
    Session.set 'clienteActual', @_id
    console.log Session.get 'clienteActual'
    $('#qHome').removeClass 'active' #limpia la botonera al clickar en un cliente

  'click #btnAlerta' : ->
  #Modal para añadir una alerta a un cliente
    Session.set 'clienteActual', @_id #guardamos el ID del cliente 
    limpiarModalAlerta()
    $('#alerta').modal 'show' #mostramos y preparamos el modal y sus elementos
  #Abrir modal para nueva nota  
  'click #btnNota' : ->
    Session.set 'clienteActual', @_id
    limpiarModalNota()
    $('#nota').modal 'show'  
  #Modal para cambiar estado de evento
  'click .linkCog' : (e)->
    Session.set 'clienteActual', e.currentTarget.getAttribute('data-id')
    Session.set 'alerta', @ 
    $('#mdlOpcionesAlerta').modal {backdrop: false}
  #Eliminar una nota
  'click #elimNota' : (e)->
    id= e.currentTarget.getAttribute('data-id')
    Clientes.update {_id: id},
      {$pull: {notas: {fecha: @fecha}}}
    updateNotas id

Template.modalOpcionesAlerta.events
  'click #btnOpcionPos' : ->
    cerrarAlerta 'positiva'

  'click #btnOpcionNeg' : ->
    cerrarAlerta 'negativa' 
    
  'click #btnOpcionDelete' : ->
    Clientes.update {_id: Session.get('clienteActual')},
                    {$pull: {alertas: {fecha: Session.get('alerta').fecha}}}
    updateAlertaCercana( Session.get('clienteActual'))
    $('#mdlOpcionesAlerta').modal('hide')

Template.modalAlerta.events
  'click #btnModalOK' : ->
    alert = {
      fecha: $('#inputFecha').val()
      texto: $('#inputTexto').val() || ""
      estado: 'activa'
    }

    #validacion de datos
    if alert.fecha == ""
      modalError('#datetimepicker',"La fecha no puede quedar vacia.")
      return  
    if alert.texto == ""
      modalError('#inputTexto','El texto no puede quedar vacio.')
      return
    
    if $('#btnAlarma').hasClass('conAlarma')
      alert.alarma = "activa"

    if $('#btnCalendario').hasClass('conCalendario')  
      id = Session.get 'clienteActual'
      cliente = Clientes.findOne {_id: id}
      dia = moment(alert.fecha, "DD-MM-YYYY HH:mm:ss").format("YYYY-MM-DD")
      gCal.insertEvent(cliente.nombre, cliente.poblacion, alert.texto,dia)

    #insertamos los datos a pelo en la ficha para probar
    id= Session.get 'clienteActual'
    Clientes.update { _id: id}, 
                    {$push : {alertas: alert}}
    updateAlertaCercana id
    $('#alerta').modal 'hide'

  'click #btnAlarma' : ->
    $('#btnAlarma').button('toggle')
    $('#btnAlarma').toggleClass('conAlarma')
  'click #btnCalendario' :->
    $('#btnCalendario').button('toggle')
    $('#btnCalendario').toggleClass('conCalendario') 

  'focus #inputTexto' : ->
    modalCleanError('#inputTexto')
  'focus #inputFecha' : ->
    modalCleanError('#datetimepicker')

Template.modalNota.events
  'click #btnNotaOK' : ->
    id = Session.get 'clienteActual'
    _texto= $('#inputNota').val()

    #validacion de campo
    if _texto == ""
      modalError('#textoNota','La nota no puede quedar vacia')
      return
    Clientes.update {_id: id},
      {$push: {notas: {fecha: moment().format("DD-MM-YYYY HH:mm:ss"), texto: _texto}}}
    $('#nota').modal 'hide'
    #flashOK 'Nota guardada correctamente'
  'focus #inputNota,#inputFecha' :->
    modalCleanError('#textoNota')
    modalCleanError('#inputFecha')

# Flash mensaje con resultado al salir del modal
#  - Calendario ok/ko principalmente
Template.flash.mensaje = ->
  return Session.get "flash" || ""

Template.flash.events
  'click #flash': ->
    flashReset()

# Login screen
Template.loginScreen.events
  'click .log-google': ->
    google.login()
    console.log 'en login (', Session.get 'logOK'
    Session.set 'logOK', true

# detalles de cliente
Template.datosCliente.datos = ->
  return Clientes.findOne {_id: Session.get 'clienteActual'}
Template.datosCliente.momentPedido = ->
  return moment(@fup,"YYYY-MM-DD").fromNow()
Template.datosCliente.moment = ->
  return moment(@fecha,"DD-MM-YYYY hh:ii:ss").fromNow()

Template.datosCliente.events
  #Opciones de una Alerta
  'click #linkCog' : (e)->
    Session.set 'clienteActual', e.currentTarget.getAttribute('data-id')
    Session.set 'alerta', @
    $('#mdlOpcionesAlerta').modal {backdrop: false}
  #Añadir una alerta a un cliente
  'click #btnAlerta' : ->
    $('#alerta').modal 'show' #mostramos y preparamos el modal y sus elementos
  #Añadir una nota
  'click #btnNota' : ->
    $('#nota').modal 'show'
  #Eliminar una de las notas
  'click #elimNota' : (e)->
    id= Session.get 'clienteActual'
    Clientes.update {_id: id},
      {$pull: {notas: {fecha: @fecha}}}
    updateNotas id

#Gestión de la barra de navegación
Template.navigate.userName = ->
  return Session.get "username"
Template.navigate.avatar = ->
  return Session.get "avatar"

Template.navigate.events
  'click #qDatos' : ->
    $('#qHome').removeClass 'active'
    $('#qDatos').addClass 'active'
    $('#qConfig').removeClass 'active'
    Session.set 'paginaActual', 'datos' 
  'click #qHome' : ->
    $('#qDatos').removeClass 'active'
    $('#qHome').addClass 'active'
    $('#qConfig').removeClass 'active'
    Session.set 'paginaActual', 'home' 
  'click #qConfig' : ->
    $('#qHome').removeClass 'active'
    $('#qDatos').removeClass 'active'
    $('#qConfig').addClass 'active'
    Session.set 'paginaActual', 'config'  

#
Template.pageRenderer.homePage = ->
  return Session.equals "paginaActual", "home"
Template.pageRenderer.datosPage = ->
  return Session.equals "paginaActual", "datos"
Template.pageRenderer.detalleCliente = ->
  return Session.equals "paginaActual", "detalleCliente"
Template.pageRenderer.configPage = ->
  return Session.equals "paginaActual", "config"

# Gestion del file uploader y de la carga del archivo de datos
# una vez cargado el archivo correctamente cambiar el boton a Importar 09/01/13
Template.fileUpload.rendered = ->  
  filepicker.constructWidget document.getElementById('uploadWidget')

Template.fileUpload.events
  'change #uploadWidget' : (event)->
    console.log "Upload done! ",event.fpfile.url
    Session.set "uploadedFileURL", event.fpfile.url
    console.log "Importando los datos"
    Session.set "mensaje", "Importando los datos del archivo."
    testIO event.fpfile.url
  'click #btnCSV' : ->
    testIO Session.get "uploadedFileURL"
  'click #btnCLEAR' : ->
    Clientes.remove({}) 
  'click #btnBackup' : ->
    Meteor.call 'backupClientes'
  'click #btnRestore': ->
    Meteor.call 'restoreClientes'
  'click #btnFixCercanas' : ->
    fixAlertasCercanas()

Template.fileUpload.mensaje = ->
  return Session.get("mensaje") || ""
  
Meteor.startup ->
  Session.set "searchData", conNotasoAlertas()
  Session.set "paginaActual","home"
  filepicker.setKey 'A4fW2SAMPSGKQh6kXZcz6z'
  moment.lang('es')

  if Meteor.userId()
    Meteor.logout ->
      console.log 'logged out'
      Session.set 'logOK', false


##########################
# Helpers
#

#limpiarModalAlerta
# resetea los inputs del modal
limpiarModalAlerta= ->
  $('#inputFecha').val('')
  $('#inputTexto').val('')
  modalCleanError('#inputTexto')
  modalCleanError('#datetimepicker')
limpiarModalNota= ->
  $('#inputNota').val('')
  modalCleanError('#textoNota')
modalError= (elem,texto)->
  $(elem).addClass('error')
  _texto = '<span class="help-block XXL" style="color:red">' +
          texto + '</span>'
  $(elem).after(_texto)
modalCleanError= (elem)->
  $(elem).removeClass('error')
  $('.help-block').remove()

#Flash message
flashOK= (msg) ->
  Session.set 'flash', msg
  $('#flash').addClass 'alert-success'
  $('#flash').slideDown()

flashKO= (msg) ->
  $('#flash').addClass 'alert-error'
  Session.set 'flash', msg
flashReset= ->
  Session.set 'flash', ""

#updateAlertaCercana
# params: id del cliente, fecha de la alerta
updateAlertaCercana= (id)->
  ficha = Clientes.findOne({_id: id})
  oldcercana = ficha.alertaCercana || ""
  console.log "old ", oldcercana, ficha.alertas.length
  if ficha.alertas.length > 0
    data = moment("2050-12-31 12:12:12","YYYY-MM-DD HH:mm:ss")
    for alerta in ficha.alertas
      if alerta.estado == "activa"
        momAlerta = moment(alerta.fecha,"DD-MM-YYYY HH:mm:ss").format("YYYY-MM-DD HH:mm:ss")
        if momAlerta < data
          data = momAlerta
    Clientes.update {_id:id}, {$set: {alertaCercana: data}}
    console.log "transformado a ", data
  else
    Clientes.update({_id: id}, {$unset: {alertas: ""}})
    Clientes.update({_id: id}, {$unset: {alertaCercana: ""}})
    console.log "Alertas vacias.. me peto los dos campos"

updateNotas= (id)->
  ficha = Clientes.findOne {_id: id}
  if ficha.notas.length == 0
    Clientes.update {_id: id}, {$unset: {notas: ""}}

# Fix alertas cercanas
# Genera el campo alertasCercanas para aquellas fichas que tienen alertas antiguas
fixAlertasCercanas= ->
  fichas = Clientes.find {alertas: {$exists: true}}
  console.log fichas.count()
  fichas.forEach (ficha)->
    if ficha.alertas.length > 0
      data = moment("2050-12-31 12:12:12","YYYY-MM-DD HH:mm:ss").format("YYYY-MM-DD HH:mm:ss")
      for alerta in ficha.alertas
        if alerta.estado == "activa"
          momAlerta = moment(alerta.fecha,"DD-MM-YYYY HH:mm:ss").format("YYYY-MM-DD HH:mm:ss")
          if momAlerta < data
            data = momAlerta
        console.log momAlerta, "<", data,"? length: ", ficha.alertas.length      
      Clientes.update {_id:ficha._id}, {$set: {alertaCercana: data}}
      console.log "updated ", ficha.nombre
    else
      Clientes.update({_id: ficha._id}, {$unset: {alertas: ""}})



#Cambia el estado de una Alerta
# Además actualiza el campo AlertaCercana
# incluye la fecha mas cercana para poder hacer un sort
cerrarAlerta= (como)->
  alert = Session.get('alerta')
  alert.estado = como
  cliente= Session.get('clienteActual')
  ficha = Clientes.findOne {_id: cliente}
  
  Clientes.update {_id: cliente},
                   {$pull: {alertas: {fecha: alert.fecha}}}
  Clientes.update {_id: cliente},
                  {$push: {alertas: alert}}
  $('#mdlOpcionesAlerta').modal('hide')

#TestIO Saca por consola el contenido del archivo que hemos subido a filepicker.io
# archivo de ejemplo
# https://www.filepicker.io/api/file/c1xiyw0tSNau2Kt2CMww
testIO= (url) ->
  if url
    filepicker.read url, (data)->
      Meteor.call 'importar', data
  else
    console.log "Error al importar el archivo desde Filepicker"

# consoleLogs all properties of an object
logProperties = (obj) ->
  for key, value of obj
    console.log "#{key}:#{value}"

conNotasoAlertas = ->
  return {$or: [{notas: {$exists:true }},{'alertas.estado': 'activa'}]}
 