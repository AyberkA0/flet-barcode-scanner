from dataclasses import field
from enum import Enum
from typing import List, Optional

import flet as ft
from flet_barcode_scanner.types import BarcodeResultEvent

__all__ = ["BarcodeScanner", "CameraFacing", "DetectionMode", "BarcodeFormat"]


class CameraFacing(Enum):
    BACK = "back"
    FRONT = "front"


class DetectionMode(Enum):
    ONCE = "once"
    CONTINUOUS = "continuous"


class BarcodeFormat(Enum):
    QR = "qr"
    CODE128 = "code128"
    EAN13 = "ean13"
    EAN8 = "ean8"
    UPCA = "upca"
    UPCE = "upce"
    PDF417 = "pdf417"
    AZTEC = "aztec"
    ALL = "all"


@ft.control("flet_barcode_scanner")
class BarcodeScanner(ft.LayoutControl):
    camera_facing: CameraFacing = CameraFacing.BACK
    detection_mode: DetectionMode = DetectionMode.ONCE
    formats: List[BarcodeFormat] = field(default_factory=list)
    torch: bool = False
    auto_close: bool = True
    overlay_title: Optional[str] = None
    on_result: Optional[ft.EventHandler[BarcodeResultEvent]] = None
    on_closed: Optional[ft.ControlEventHandler["BarcodeScanner"]] = None

    async def start(self):
        await self._invoke_method("start")

    async def stop(self):
        await self._invoke_method("stop")

    def set_formats(self, *formats: BarcodeFormat):
        self.formats = list(formats)
