from dataclasses import dataclass
from typing import TYPE_CHECKING

import flet as ft

if TYPE_CHECKING:
    from flet_barcode_scanner.barcode_scanner import BarcodeScanner

__all__ = ["BarcodeResultEvent"]


@dataclass
class BarcodeResultEvent(ft.Event["BarcodeScanner"]):
    raw_value: str
    format: str
    timestamp: str
