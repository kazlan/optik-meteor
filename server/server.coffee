Clientes = new Meteor.Collection 'clientes'

Meteor.startup ->
  alertCheck = Meteor.setInterval checkAlertas, 60000
  setGoogle()

  Meteor.publish "userinfo", ->
    return Meteor.users.find({_id: this.userId}, {fields: {profile: 1, services: 1}})

  Meteor.publish "listaClientes", (data)->
    return Clientes.find(data,{sort: {'alertaCercana': 1}})

#setGoogle
# Inserta los datos privados de google en la DB
setGoogle= ->
  Accounts.loginServiceConfiguration.remove({
    service: "google"
    })
  Accounts.loginServiceConfiguration.insert({
    service: "google",
    clientId: "1414940972-0omthsijccn5ej5jldpj4smsqm5vkrf3.apps.googleusercontent.com",
    secret: "VJM-dWpdVV8j-spgfk8dVwZT"
    });

########################
# checkAlertas:
#  - Recoge las alertas que acaban de expirar en el ultimo tick
#      * fecha < now
#      * alarma: true
#  - envia correo y pasa alarma a false
checkAlertas = ->
  conAlarmas = Clientes.find {'alertas.alarma': 'activa'}	
  console.log 'tick', conAlarmas.count()

  conAlarmas.forEach (cliente)-> 
  	for alerta in cliente.alertas
  	  if alerta.alarma == "activa"
  	   dateAlerta = moment(alerta.fecha,"DD-MM-YYYY HH:mm:ss").format("YYYY-MM-DD HH:mm:ss")
  	   now = moment().format("YYYY-MM-DD HH:mm:ss")
  	   #El tiempo en el server es GMT+0 por eso añadimos una hora
  	   console.log "es ", dateAlerta, " < ", now , "?"
  	   if dateAlerta< now
  	     console.log cliente.nombre," listo para enviar correo."	
  	     try 
  	       Email.send({
  	     	 from: 'alertas@optik.meteor.com',
  	     	 to: 'cuestaeugenia@gmail.com',
  	     	 cc: 'jorge.mollon@gmail.com'
  	     	 #to: 'jorge.mollon@gmail.com',
  	     	 subject: cliente.nombre,
  	     	 text: alerta.texto
  	     	 })
  	     catch error
  	       console.log error 

  	     delete alerta.alarma
  	     Clientes.update {_id: cliente._id}, cliente
