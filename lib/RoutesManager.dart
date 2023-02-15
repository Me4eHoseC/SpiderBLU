class RoutesManager{
  static int _laptopAddress = 998;

  static int getLaptopAddress(){
    return _laptopAddress;
  }

  static void setLaptopAddress(int address){
    _laptopAddress = address;
  }

  static int getBroadcastAddress(){
    return 999;
  }

  static int getRetransmissionAllAddress(){
    return 0xFFFF;
  }
}