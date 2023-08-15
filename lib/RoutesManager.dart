class RoutesManager {
  static int _laptopAddress = 998;

  static int getLaptopAddress() {
    return _laptopAddress;
  }

  static void setLaptopAddress(int address) {
    _laptopAddress = address;
  }

  static int getBroadcastAddress() {
    return 999;
  }

  static int getRtAllHop() {
    return 0xFFFF;
  }

  static RtMode getRtMode(List<int> hops) {
    if (hops.isEmpty) return RtMode.NoOne;
    if (hops[0] == 0) return RtMode.NoOne;

    var hasToAllHop = hops.contains(getRtAllHop());

    if (hasToAllHop) {
      return RtMode.ToAll;
    } else {
      return RtMode.Tree;
    }
  }
}

enum RtMode {
  NoOne,
  Tree,
  ToAll;
}
