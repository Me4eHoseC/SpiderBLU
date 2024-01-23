import 'dart:core';

class Reference<T> {
  T value;

  Reference(this.value);
}

class Marker {
  int _id = 0;

  double _latitude = 0.0;
  double _longitude = 0.0;
  double _storedLatitude = 0.0;
  double _storedLongitude = 0.0;

  void copyFrom(Marker other){
    _id = other._id;
    _latitude = other._latitude;
    _longitude = other._longitude;
    _storedLatitude = other._storedLatitude;
    _storedLongitude = other._storedLongitude;
  }

  Marker clone() {
    var marker = Marker();
    marker.copyFrom(this);
    return marker;
  }

  static String Name([bool isTr = false]){
    return isTr ? "Marker" : "Marker";
  }

  String typeName([bool isTr = false]){
    return Marker.Name(isTr);
  }

  int get id => _id;
  set id(int id) => _id = id;

  double get latitude => _latitude;
  double get longitude => _longitude;

  void setCoordinates(double latitude, longitude){
    _latitude = latitude;
    _longitude = longitude;
  }

  double get storedLatitude => _storedLatitude;
  double get storedLongitude => _storedLongitude;

  void setStoredCoordinates(double latitude, longitude){
    _storedLatitude = latitude;
    _storedLongitude = longitude;
  }
}