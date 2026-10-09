import flet as ft
from flet_barcode_scanner import (
    BarcodeScanner,
    BarcodeResultEvent,
    CameraFacing,
    DetectionMode,
    BarcodeFormat,
)


def main(page: ft.Page):
    page.title = "Flet Barcode Scanner"

    result = ft.Text("No code scanned yet.", selectable=True)
    status = ft.Text("Idle")

    def on_result(e: BarcodeResultEvent):
        result.value = f"Value: {e.raw_value}\nFormat: {e.format}"
        status.value = "Detected"
        page.update()

    def on_closed(e: ft.ControlEvent):
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

    async def start_scan(e):
        status.value = "Scanning..."
        page.update()
        await scanner.start()

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
