import 'package:flet/flet.dart';
import 'package:flutter/widgets.dart';
import 'flet_barcode_scanner.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  if (args.control.type == "flet_barcode_scanner") {
    return FletBarcodeScannerControl(
      parent: args.parent,
      control: args.control,
      children: args.children,
      parentDisabled: args.parentDisabled,
      parentAdaptive: args.parentAdaptive,
      backend: args.backend,
    );
  }
  return null;
};

Future<void> ensureInitialized() async {}
