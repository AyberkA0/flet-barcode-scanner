import 'dart:convert';
import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FletBarcodeScannerControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final List<Control> children;
  final bool parentDisabled;
  final bool? parentAdaptive;
  final FletControlBackend backend;

  const FletBarcodeScannerControl({
    super.key,
    required this.parent,
    required this.control,
    required this.children,
    required this.parentDisabled,
    required this.parentAdaptive,
    required this.backend,
  });

  @override
  State<FletBarcodeScannerControl> createState() => _FletBarcodeScannerControlState();
}

class _FletBarcodeScannerControlState extends State<FletBarcodeScannerControl> {
  bool _scannerOpen = false;

  @override
  void initState() {
    super.initState();
    widget.backend.subscribeMethods(widget.control.id, _onMethodCall);
  }

  @override
  void dispose() {
    widget.backend.unsubscribeMethods(widget.control.id);
    super.dispose();
  }

  Future<String?> _onMethodCall(String method, Map<String, String> args) async {
    switch (method) {
      case "start":
        if (!_scannerOpen && mounted) {
          _scannerOpen = true;
          final result = await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => _ScannerPage(control: widget.control),
            ),
          );
          _scannerOpen = false;
          final reason = result == null ? "canceled" : "detected";
          widget.backend.triggerControlEvent(widget.control.id, "closed", reason);
          if (result != null) {
            widget.backend.triggerControlEvent(
              widget.control.id,
              "result",
              json.encode(result),
            );
          }
        }
        return "started";
      case "stop":
        if (_scannerOpen && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
          return "stopped";
        }
        return "idle";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return baseControl(
      context,
      const SizedBox.shrink(),
      widget.parent,
      widget.control,
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
  late final MobileScannerController _controller;
  bool _handledOnce = false;

  @override
  void initState() {
    super.initState();
    final facingStr = widget.control.attrString("cameraFacing", "back");
    final detectionMode = widget.control.attrString("detectionMode", "once");
    final formatsJson = widget.control.attrString("formats");
    final torchInitiallyOn = widget.control.attrBool("torch", false) ?? false;
    final facing = (facingStr?.toLowerCase() == "front") ? CameraFacing.front : CameraFacing.back;
    final List<BarcodeFormat> formats = [];
    if (formatsJson != null) {
      try {
        final List<dynamic> fs = json.decode(formatsJson);
        for (final f in fs.map((e) => e.toString().toLowerCase())) {
          switch (f) {
            case "qr":
            case "qrcode":
              formats.add(BarcodeFormat.qrCode);
              break;
            case "code128":
              formats.add(BarcodeFormat.code128);
              break;
            case "ean13":
              formats.add(BarcodeFormat.ean13);
              break;
            case "ean8":
              formats.add(BarcodeFormat.ean8);
              break;
            case "upca":
              formats.add(BarcodeFormat.upcA);
              break;
            case "upce":
              formats.add(BarcodeFormat.upcE);
              break;
            case "pdf417":
              formats.add(BarcodeFormat.pdf417);
              break;
            case "aztec":
              formats.add(BarcodeFormat.aztec);
              break;
            case "all":
              formats.clear();
              break;
          }
        }
      } catch (_) {}
    }
    _controller = MobileScannerController(
      facing: facing,
      formats: formats,
      torchEnabled: torchInitiallyOn,
    );
    _handledOnce = (detectionMode?.toLowerCase() ?? "once") == "once" ? false : false;
  }

  void _onDetect(BarcodeCapture cap) {
    if (!mounted) return;
    final autoClose = widget.control.attrBool("autoClose", true) ?? true;
    final detectionMode = widget.control.attrString("detectionMode", "once");
    for (final b in cap.barcodes) {
      final raw = b.rawValue ?? "";
      final fmt = b.format.name;
      final payload = {
        "rawValue": raw,
        "format": fmt,
        "timestamp": DateTime.now().toIso8601String(),
      };
      if ((detectionMode?.toLowerCase() ?? "once") == "once") {
        if (!_handledOnce) {
          _handledOnce = true;
          if (autoClose) {
            Navigator.of(context, rootNavigator: true).pop(payload);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.control.attrString("overlayTitle", "Kodu kameraya gösterin") ?? "";
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: MobileScanner(
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
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
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
