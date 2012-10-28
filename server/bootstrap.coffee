Clientes = new Meteor.Collection 'clientes'

Meteor.startup ->
  if Clientes.find().count() == 0
    data = {
      nombre: "john doe",
      direccion: "calle",
      ciudad: "valencia",
      provincia: "valencia",
      telefono: "961303030",	
      citas:[
        {fecha: "date object",
        texto: "lalalala",
        agente: "nombre"}
      ]
    }
    Clientes.insert(data)
    data = {
      nombre: "jenna doe",
      direccion: "avda lerele",
      ciudad: "cheste",
      provincia: "valencia",
      telefono: "96120323",	
      citas:[
        {fecha: "date object2",
        texto: "lerelele",
        agente: "nombre2"}
      ],
      alertas: [
        {tipo: "llamar/visitar",
        fecha: "date",
        agente: "nombre"}]
    }
    Clientes.insert(data)