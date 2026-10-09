import 'package:flet/flet.dart';
import 'package:flutter/widgets.dart';

import 'barcode_scanner_control.dart';

class Extension extends FletExtension {
  @override
  Widget? createWidget(Key? key, Control control) {
    switch (control.type) {
      case "flet_barcode_scanner":
        return BarcodeScannerControl(key: key, control: control);
      default:
        return null;
    }
  }
}
