Accounts.ui.config({requestPermissions: {google: 
  ['https://www.googleapis.com/auth/calendar',
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/tasks']}}, requestOfflineToken: {google: true})

gCal = 
  insertEvent: (cliente, poblacion, texto, fecha)->
  #to-do calendar devuelve un Event Object que incluye un ID
  # si incluimos este id como campo en la alerta podremos despues
  # eliminar el evento en el calendario directamente desde la app
    status = "ok"
    url = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
    event=  {
      summary: cliente
      location: poblacion
      description: texto
      start:
        "date": fecha
      end:
        "date": fecha
      }
    evento = JSON.stringify event
    Auth = 'Bearer ' + Meteor.user().services.google.accessToken
    status = Meteor.http.post url, {
      params: {key: 'AIzaSyDe3u-N3m-lfVDuqAc0fpH2npB785uYgrQ'},
      data: event,
      headers: {'Authorization': Auth }
      }, 
      (err, result)->
        if err
          console.log err
          flashKO "No se pudo añadir la alerta a Google Calendar!"
          return "ko"
        else
          flashOK "La alerta se añadió a Google Calendar" 
          return result.id
    console.log status
  #removeEvent: (id)->
  #	url = 'https://www.googleapis.com/calendar/v3/calendars/primary/events/' + id
  #  Auth= 'Bearer ' + Meteor.user().services.google.accessToken
  #	Meteor.http.del url, {
  #		params: {key: 'AIzaSyDe3u-N3m-lfVDuqAc0fpH2npB785uYgrQ'},
  #		headers: {'Authorization': Auth}
  #	}, (err, result)->
  #		console.log result

