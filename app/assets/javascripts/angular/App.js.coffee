L.Icon.Default.imagePath = 'assets/'
angular.module "SustainabilityApp", ["leaflet-directive", "rails", "ngTagsInput", "Devise", "ngDialog"]
.config [
  "AuthProvider"
  (AuthProvider) ->
    AuthProvider.loginPath '/api/users/sign_in.json'
    AuthProvider.logoutPath '/api/users/sign_out.json'
    AuthProvider.registerPath '/api/users.json'
    #AuthProvider.ignoreAuth(true)

]
