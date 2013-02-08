Template.editorFicha.events
  'click #btnLoadFicha' : ->
  	console.log 'click'
  	nombre = $('#inputNombre').val().toUpperCase()
  	console.log Clientes.findOne {nombre: {$regex: nombre}}
