import flet as ft
from flet_barcode_scanner import BarcodeScanner, CameraFacing

def main(page: ft.Page):
    page.title = "Flet Barcode Scanner"
    page.padding = 20
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    page.vertical_alignment = ft.MainAxisAlignment.CENTER

    status = ft.Text("Ready")
    last = ft.Text("", selectable=True)

    def on_detect(e: ft.ControlEvent):
        last.value = e.data
        status.value = "Detected"
        page.update()

    scanner = BarcodeScanner(
        on_detect=on_detect,
        facing=CameraFacing.BACK,
        torch=False,
        width=360,
        height=360,
    )

    def start_scan(_):
        status.value = "Scanning"
        page.update()
        scanner.start()

    def stop_scan(_):
        status.value = "Stopped"
        page.update()
        scanner.stop()

    actions = ft.Row(
        controls=[
            ft.ElevatedButton("Start", on_click=start_scan),
            ft.OutlinedButton("Stop", on_click=stop_scan),
            ft.FilledButton("Toggle torch", on_click=lambda _: scanner.toggle_torch()),
            ft.TextButton("Switch camera", on_click=lambda _: scanner.switch_camera()),
        ],
        alignment=ft.MainAxisAlignment.CENTER,
        wrap=True,
    )

    page.add(
        ft.Column(
            controls=[
                ft.Container(content=scanner, width=360, height=360, bgcolor=ft.Colors.BLACK, border_radius=12),
                actions,
                ft.Text("Last result:"),
                last,
                status,
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            spacing=16,
        )
    )

if __name__ == "__main__":
    ft.app(target=main)