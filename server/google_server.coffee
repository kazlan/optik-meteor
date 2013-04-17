#Google server side
Meteor.methods
  refreshToken: -> 
	console.log "dentro de refreskToken serverside"
	url =  "https://accounts.google.com/o/oauth2/token/" 
	userData = Meteor.users.findOne({id: this.userId}).services.google
	googleConf = Accounts.loginServiceConfiguration.findOne({'service': 'google'})
	console.log "Estoy refrescando el token"
	_headers = 
	  'Content-Type': 'application/x-www-form-urlencoded'
	  'Content': 'refresh_token=' + userData.refreshToken + 
	    '&client_id=' + googleConf.clientId + 
	    '&client_secret=' + googleConf.secret + 
	    '&grant_type=' + 'refresh_token'
	console.log _headers
	result = Meteor.http.post url, {headers: _headers}
	console.log result