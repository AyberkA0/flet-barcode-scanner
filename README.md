# Flet Barcode Scanner Extension

A lightweight barcode/QR scanner extension for [Flet](https://flet.dev) built on top of Flutter's `mobile_scanner`.

---

## ✨ Features

- Realtime barcode & QR detection
- Back/Front camera selection
- Torch (flash) control
- Event callback on detection (`on_detect`)
- Simple, Flet-friendly API

---

## ⚠️ Important Note

When running your app **without building** the extension using `flet build ...`, you will see an **error box** instead of the actual scanner widget.  
To see the real widget, you **must build** the extension for your target platform.  

---

## 📦 Installation

Install directly from GitHub:

```bash
pip install git+https://github.com/AyberkA0/flet-barcode-scanner.git
````

Add it to your `pyproject.toml`:

```toml
[project]
dependencies = [
  "flet==0.28.3",
  "flet-barcode-scanner @ git+https://github.com/AyberkA0/flet-barcode-scanner",
]
```

---

## 🚀 Usage Example

```python
import json
import flet as ft
from flet_barcode_scanner import (
    BarcodeScanner,
    CameraFacing,
    DetectionMode,
    BarcodeFormat,
)

def main(page: ft.Page):
    page.title = "Flet Barcode Scanner"

    result = ft.Text("No code scanned yet.", selectable=True)
    status = ft.Text("Idle")

    def on_result(e: ft.ControlEvent):
        try:
            data = json.loads(e.data or "{}")
            raw = data.get("rawValue", "")
            fmt = data.get("format", "")
            result.value = f"Value: {raw}\nFormat: {fmt}"
        except Exception:
            result.value = f"Raw: {e.data}"
        status.value = "Detected"
        page.update()

    def on_closed(e: ft.ControlEvent):
        # e.data -> "detected" or "canceled"
        status.value = f"Closed: {e.data}"
        page.update()

    scanner = BarcodeScanner(
        camera_facing=CameraFacing.BACK,
        detection_mode=DetectionMode.ONCE,
        formats=[BarcodeFormat.QR, BarcodeFormat.CODE128, BarcodeFormat.PDF417],
        torch=False,
        auto_close=True,
        overlay_title="Show the code to the camera",
        on_result=on_result,
        on_closed=on_closed,
    )

    def start_scan(_):
        status.value = "Scanning..."
        page.update()
        scanner.start()

    page.overlay.append(scanner)
    page.add(
        ft.Column(
            [
                ft.ElevatedButton("Open Scanner", on_click=start_scan),
                result,
                status,
            ]
        )
    )

ft.app(target=main)
```

---

## 🗂️ Project Structure

```
flet-barcode-scanner/
├── src/
│   ├── flet_barcode_scanner/         # Python API for Flet
│   └── flutter/flet_barcode_scanner/ # Flutter implementation (mobile_scanner)
├── examples/
│   └── flet_barcode_scanner_example/ # Example usage
├── README.md
├── pyproject.toml
└── LICENSE
```

---

## 🧑‍💻 Development

1. Clone the repository

```bash
git clone https://github.com/AyberkA0/flet-barcode-scanner.git
cd flet-barcode-scanner
```

2. Install dependencies

```bash
pip install "flet[all]" --upgrade
pip install -e .
```

3. Run the example

```bash
cd examples/flet_barcode_scanner_example
flet run
```

---

## Notes

* Built for Flet `0.28.3`
* Works on MacOS, Linux, and Mobile (camera access may vary by platform/permissions)
