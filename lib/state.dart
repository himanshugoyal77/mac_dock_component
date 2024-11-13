import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  var items = <IconData>[
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ].obs;

  void onAcceptWithDetails(data, e) {
    int fromIndex = int.parse(data.data.toString());
    int toIndex = items.indexOf(e);
    if (fromIndex == toIndex || fromIndex == -1 || toIndex == -1) return;

    IconData movedElement = items[fromIndex];
    List<IconData> _items = items; // Creates a new list copy
    List<IconData> temp = items;

    if (fromIndex < toIndex) {
      for (int i = fromIndex; i < toIndex; i++) {
        _items[i] = temp[i + 1];
      }
    } else {
      for (int i = fromIndex; i > toIndex; i--) {
        _items[i] = temp[i - 1];
      }
    }

    _items[toIndex] = movedElement;
  }
}
