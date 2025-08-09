````markdown
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
import flet as ft
from flet_barcode_scanner import BarcodeScanner, ScannerFacing

def main(page: ft.Page):
    page.title = "Flet Barcode Scanner"
    page.padding = 20
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    page.vertical_alignment = ft.MainAxisAlignment.CENTER

    result = ft.Text("", selectable=True)

    def on_detect(e: ft.ControlEvent):
        result.value = e.data
        page.update()

    scanner = BarcodeScanner(
        on_detect=on_detect,
        facing=ScannerFacing.BACK,
        torch=False,
        width=360,
        height=360,
    )

    toggle_torch = ft.ElevatedButton("Toggle torch", on_click=lambda _: scanner.toggle_torch())
    switch_cam = ft.OutlinedButton("Switch camera", on_click=lambda _: scanner.switch_camera())

    page.add(
        ft.Column(
            controls=[
                ft.Container(content=scanner, width=360, height=360, bgcolor=ft.Colors.BLACK, border_radius=12),
                ft.Row([toggle_torch, switch_cam], alignment=ft.MainAxisAlignment.CENTER),
                ft.Text("Last result:"),
                result,
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            spacing=16,
        )
    )

if __name__ == "__main__":
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