import 'dart:async';

import 'Marker.dart';
import 'Device.dart';

class ItemsManager {
  final Map<int, Marker> _items = {};
  Marker? _selectedItem;

  late void Function(int itemId, CommonItemType commonItemType) itemAdded;
  late void Function(int itemId, CommonItemType commonItemType) itemRemoved;

  Marker createItem(Type itemType,
      [int itemId = -1, DeviceType deviceType = DeviceType.CSD]) {
    if (itemId == -1) itemId = getFreeId();

    var item = get(itemId);
    if (item != null) return item;

    if (itemType == Marker) {
      item = Marker();
    } else {
      item = Device();
      (item as Device).type = deviceType;
    }

    item.id = itemId;
    _items[itemId] = item;

    CommonItemType cit = CommonItemType.Marker;
    if (itemType == Device) {
      switch (deviceType) {
        case DeviceType.STD:
          cit = CommonItemType.STD;
          break;
        case DeviceType.CSD:
          cit = CommonItemType.CSD;
          break;
        case DeviceType.CPD:
          cit = CommonItemType.CPD;
          break;
        case DeviceType.RT:
          cit = CommonItemType.RT;
          break;
      }
    }

    Timer.run(() => itemAdded(itemId, cit));
    return item;
  }

  void removeItem(int itemId) {
    var it = _items[itemId];
    if (it == null) return;

    if (isItemSelected(itemId)) {
      clearSelection();
    }

    CommonItemType cit = CommonItemType.Marker;
    if (it.runtimeType == Device) {
      switch ((it as Device).type) {
        case DeviceType.STD:
          cit = CommonItemType.STD;
          break;
        case DeviceType.CSD:
          cit = CommonItemType.CSD;
          break;
        case DeviceType.CPD:
          cit = CommonItemType.CPD;
          break;
        case DeviceType.RT:
          cit = CommonItemType.RT;
          break;
      }
    }
    Timer.run(() => itemRemoved(itemId, cit));

    _items.remove(it);
  }

  void changeItemId(int itemId, int newItemId) {
    var it = _items[itemId];
    if (it == null) return;

    _items.remove(itemId);

    it.id = newItemId;
    _items[newItemId] = it;
  }

  Marker? get(int itemId) {
    return _items[itemId];
  }

  Device? getDevice(int deviceId) {
    var device = get(deviceId);
    if (device == null) return null;

    if (device is! Device) return null;
    return device;
  }

  bool isItemSelected(int itemId) {
    if (_selectedItem == null) return false;
    return _selectedItem?.id == itemId;
  }

  Marker? getSelectedItem() {
    return _selectedItem;
  }

  Device? getSelectedDevice() {
    if (_selectedItem == null) return null;
    if (_selectedItem is! Device) return null;

    return _selectedItem as Device;
  }

  void setSelectedItem(int itemId) {
    _selectedItem = get(itemId);
  }

  void clearSelection() {
    _selectedItem = null;
  }

  List<Marker> getItems() {
    return _items.values.toList();
  }

  List<Marker> getItemsOfType(Type itemType) {
    List<Marker> itemsVector = [];
    for (var item in _items.values) {
      if (item.runtimeType == itemType) {
        itemsVector.add(item);
      }
    }
    return itemsVector;
  }

  List<int> getItemsIds() {
    List<int> idsVector = [];
    for (var item in _items.values) {
      idsVector.add(item.id);
    }
    return idsVector;
  }

  int getFreeId() {
    var id = 1;
    while (get(id) != null) {
      id += 1;
    }
    return id;
  }
}

enum CommonItemType {
  STD,
  RT,
  CSD,
  CPD,
  Marker;
}
