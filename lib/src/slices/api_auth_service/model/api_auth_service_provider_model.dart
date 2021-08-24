import 'api_auth_service_model.dart';

/// The Provider Model for Auth Service
///
/// This provider should be defined at res/json/auth_providers_db.json in the
/// following format:
///     "provider_name" : {
///         "clientId" : the client identifier for the provider
///         "authorizationEndpoint" : auth url
///         "tokenEndpoint" : token url
///         "redirectUrl" : redirect url (default [ApiAuthServiceModel.redirectUrl])
///         "discoveryUrl" : discovery url
///     }
///
class ApiAuthServiceProviderModel {
  late String clientId;
  late String authorizationEndpoint;
  late String tokenEndpoint;
  late String discoveryUrl;
  late String redirectUrl;

  ApiAuthServiceProviderModel.fromMap(map) {
    clientId = map['clientId'];
    authorizationEndpoint = map['authorizationEndpoint'];
    tokenEndpoint = map['tokenEndpoint'];
    redirectUrl = map['redirectUrl'] ?? ApiAuthServiceModel.redirectUrl;
    discoveryUrl = map['discoveryUrl'];
  }
}
