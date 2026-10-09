import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;

class BarcodeScannerControl extends StatefulWidget {
  final Control control;

  const BarcodeScannerControl({super.key, required this.control});

  @override
  State<BarcodeScannerControl> createState() => _BarcodeScannerControlState();
}

class _BarcodeScannerControlState extends State<BarcodeScannerControl> {
  bool _scannerOpen = false;

  @override
  void initState() {
    super.initState();
    widget.control.addInvokeMethodListener(_invokeMethod);
  }

  @override
  void dispose() {
    widget.control.removeInvokeMethodListener(_invokeMethod);
    super.dispose();
  }

  Future<dynamic> _invokeMethod(String name, dynamic args) async {
    switch (name) {
      case "start":
        if (!_scannerOpen && mounted) {
          _scannerOpen = true;
          final result =
              await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<Map<String, String>>(
              fullscreenDialog: true,
              builder: (_) => _ScannerPage(control: widget.control),
            ),
          );
          _scannerOpen = false;
          widget.control.triggerEvent(
            "closed",
            result == null ? "canceled" : "detected",
          );
        }
        return "started";
      case "stop":
        if (_scannerOpen &&
            Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
          return "stopped";
        }
        return "idle";
      default:
        throw Exception("Unknown BarcodeScanner method: $name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutControl(
      control: widget.control,
      child: const SizedBox.shrink(),
    );
  }
}

class _ScannerPage extends StatefulWidget {
  final Control control;
  const _ScannerPage({required this.control});

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  late final ms.MobileScannerController _controller;
  bool _handledOnce = false;

  @override
  void initState() {
    super.initState();

    final facing =
        widget.control.getString("camera_facing", "back") == "front"
            ? ms.CameraFacing.front
            : ms.CameraFacing.back;
    final formats = _parseFormats(widget.control.get("formats"));
    final torch = widget.control.getBool("torch", false)!;

    _controller = ms.MobileScannerController(
      facing: facing,
      formats: formats,
      torchEnabled: torch,
    );
  }

  List<ms.BarcodeFormat> _parseFormats(dynamic raw) {
    final out = <ms.BarcodeFormat>[];
    if (raw is! List) return out;
    for (final item in raw) {
      switch (item.toString().toLowerCase()) {
        case "qr":
        case "qrcode":
          out.add(ms.BarcodeFormat.qrCode);
          break;
        case "code128":
          out.add(ms.BarcodeFormat.code128);
          break;
        case "ean13":
          out.add(ms.BarcodeFormat.ean13);
          break;
        case "ean8":
          out.add(ms.BarcodeFormat.ean8);
          break;
        case "upca":
          out.add(ms.BarcodeFormat.upcA);
          break;
        case "upce":
          out.add(ms.BarcodeFormat.upcE);
          break;
        case "pdf417":
          out.add(ms.BarcodeFormat.pdf417);
          break;
        case "aztec":
          out.add(ms.BarcodeFormat.aztec);
          break;
        case "all":
          return <ms.BarcodeFormat>[];
      }
    }
    return out;
  }

  void _onDetect(ms.BarcodeCapture cap) {
    if (!mounted) return;
    final autoClose = widget.control.getBool("auto_close", true)!;
    final continuous =
        widget.control.getString("detection_mode", "once") == "continuous";

    for (final b in cap.barcodes) {
      final payload = {
        "raw_value": b.rawValue ?? "",
        "format": b.format.name,
        "timestamp": DateTime.now().toIso8601String(),
      };

      if (continuous) {
        widget.control.triggerEvent("result", payload);
        continue;
      }

      if (!_handledOnce) {
        _handledOnce = true;
        widget.control.triggerEvent("result", payload);
        if (autoClose) {
          Navigator.of(context, rootNavigator: true).pop(payload);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.control.getString("overlay_title", "") ?? "";
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ms.MobileScanner(
                controller: _controller,
                fit: BoxFit.cover,
                onDetect: _onDetect,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: kToolbarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true)
                                .pop(null),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.flash_on),
                        onPressed: () => _controller.toggleTorch(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
