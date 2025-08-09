import flet as ft

from flet_barcode_scanner import FletBarcodeScanner


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    page.add(

                ft.Container(height=150, width=300, alignment = ft.alignment.center, bgcolor=ft.Colors.PURPLE_200, content=FletBarcodeScanner(
                    tooltip="My new FletBarcodeScanner Control tooltip",
                    value = "My new FletBarcodeScanner Flet Control", 
                ),),

    )


ft.app(main)
