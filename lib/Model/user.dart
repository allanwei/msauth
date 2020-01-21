class User{
   String aud;
   String iss;
   String familyName;
   String givenName;
   String name;
   String uid;
   String upn;
   String accessToken;
   String refreshToken;

  User({this.aud, this.iss, this.familyName, this.givenName, this.name, this.uid, this.upn,this.accessToken,this.refreshToken});
  factory User.fromJson(Map<String,dynamic> json){
    return new User(
  uid:json["oid"],
  aud:json["aud"],
  iss:json["iss"],
  familyName:json["family_name"],
  givenName:json["given_name"],
  name:json["name"],
  upn:json["upn"],
  accessToken: json["access_token"],
  refreshToken: json["refresh_token"]);
  
  }
  static Map toJsonMap(User model) {
    Map ret = new Map();
    if (model != null) {
      if (model.aud != null) {
        ret["aud"] = model.aud;
      }
      if (model.uid != null) {
        ret["oid"] = model.uid;
      }
      if (model.iss != null ) {
        ret["iss"] = model.iss;
      }
      if (model.familyName != null ) {
        ret["family_name"] = model.familyName;
      }
      if (model.givenName != null ) {
        ret["given_name"] = model.givenName;
      }  
      if (model.upn != null ) {
        ret["upn"] = model.upn;
      }     
      if(model.name !=null){
        ret["name"]=model.name;
      }
       if (model.accessToken != null ) {
        ret["access_token"] = model.accessToken;
      }       
        if (model.refreshToken != null ) {
        ret["refresh_token"] = model.refreshToken;
      }       

    }
    return ret;
  }

  static User fromMap(Map map) {
    if (map == null)
      throw new Exception("No token from received");
    //error handling as described in https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow#error-response-1
    if ( map["error"] != null )
      throw new Exception("Error during token request: " + map["error"] + ": " + map["error_description"]);

    User model = new User();
    model.aud = map["aud"];
    model.iss = map["iss"];
    model.familyName = map["family_name"];
    model.givenName = map["given_name"];
    model.name =map["name"];
    model.uid = map["oid"];
    model.upn = map["upn"];
    model.accessToken=map["access_token"];
    model.refreshToken=map["refresh_token"];
    return model;
  }
  
}