import 'dart:async';
import 'Marker.dart';

class ItemsManager {
  final Map<int, Marker> _items = {};
  Marker? _selectedItem;

  late void Function(int itemId) itemAdded;
  late void Function(int itemId) itemRemoved;

  late void Function() selectionChanged;

  bool _blockSignals = false;
  set blockSignals(bool value) => _blockSignals = value;

  void addItem(Marker item) {
    var itemId = item.id;
    if (get<Marker>(itemId) != null) return;

    _items[itemId] = item;
    if (!_blockSignals) {
      Timer.run(() => itemAdded(itemId));
    }
  }

  void removeItem(int itemId) {
    if (!_items.containsKey(itemId)) {
      return;
    }

    if (isSelected(itemId)) {
      clearSelection();
    }

    if (!_blockSignals) {
      Timer.run(() => itemRemoved(itemId));
    }
    _items.remove(itemId);
  }

  void changeItemId(int itemId, int newItemId) {
    var mark = _items[itemId];
    if (mark == null) return;

    _items.remove(itemId);

    mark.id = newItemId;
    _items[newItemId] = mark;
  }

  T? get<T>(int itemId) {
    if (!_items.containsKey(itemId)) {
      return null;
    }

    if (_items[itemId] is! T) {
      return null;
    }

    return _items[itemId] as T;
  }

  List<T> getAll<T>() {
    List<T> itemsVector = [];
    for (Marker marker in _items.values){
      if (marker is! T){
        continue;
      }
      itemsVector.add(marker as T);
    }
    return itemsVector;
  }

  List<int> getAllIds() {
    List<int> idsVector = [];
    idsVector.addAll(_items.keys);
    return idsVector;
  }

  T? getSelected<T>() {
    return _selectedItem is T ? _selectedItem as T : null;
  }

  void setSelected(int itemId) {
    _selectedItem = get<Marker>(itemId);
    if (!_blockSignals) {
      Timer.run(() => selectionChanged());
    }
  }

  bool isSelected(int itemId) {
    if (_selectedItem == null) return false;
    return _selectedItem!.id == itemId;
  }

  void clearSelection() {
    _selectedItem = null;
    if (!_blockSignals) {
      Timer.run(() => selectionChanged());
    }
  }

  int getNextId() {
    var id = 1;
    while (get<Marker>(id) != null) {
      id += 1;
    }
    return id;
  }
}
