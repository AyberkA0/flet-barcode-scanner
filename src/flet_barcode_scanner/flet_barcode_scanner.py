from __future__ import annotations
import json
from enum import Enum
from typing import Any, Iterable, List, Optional
from flet.core.control import Control
from flet.core.types import OptionalControlEventCallable

class CameraFacing(str, Enum):
    BACK = "back"
    FRONT = "front"

class DetectionMode(str, Enum):
    ONCE = "once"
    CONTINUOUS = "continuous"

class BarcodeFormat(str, Enum):
    QR = "qr"
    CODE128 = "code128"
    EAN13 = "ean13"
    EAN8 = "ean8"
    UPCA = "upca"
    UPCE = "upce"
    PDF417 = "pdf417"
    AZTEC = "aztec"
    ALL = "all"

def _norm_str(x: Optional[str]) -> Optional[str]:
    return x.lower() if isinstance(x, str) else x

def _ensure_enum_member(value: str, enum_cls) -> str:
    allowed = {e.value for e in enum_cls}
    if value not in allowed:
        raise ValueError(f"Invalid value '{value}' for {enum_cls.__name__}. Allowed: {sorted(allowed)}")
    return value

class FletBarcodeScanner(Control):
    def __init__(
        self,
        tooltip: Optional[str] = None,
        visible: Optional[bool] = None,
        data: Any = None,
        *,
        camera_facing: Optional[CameraFacing | str] = CameraFacing.BACK,
        detection_mode: Optional[DetectionMode | str] = DetectionMode.ONCE,
        formats: Optional[Iterable[BarcodeFormat | str]] = None,
        torch: Optional[bool] = False,
        auto_close: Optional[bool] = True,
        overlay_title: Optional[str] = None,
    ):
        Control.__init__(self, tooltip=tooltip, visible=visible, data=data)
        self.camera_facing = camera_facing
        self.detection_mode = detection_mode
        self.formats = list(formats) if formats is not None else None
        self.torch = torch
        self.auto_close = auto_close
        self.overlay_title = overlay_title
        self.on_result: OptionalControlEventCallable = None
        self.on_closed: OptionalControlEventCallable = None

    def _get_control_name(self):
        return "flet_barcode_scanner"

    @property
    def camera_facing(self) -> Optional[str]:
        return self._get_attr("cameraFacing")

    @camera_facing.setter
    def camera_facing(self, value: Optional[CameraFacing | str]):
        if isinstance(value, CameraFacing):
            v = value.value
        else:
            v = _norm_str(value)
        if v is not None:
            v = _ensure_enum_member(v, CameraFacing)
        self._set_attr("cameraFacing", v)

    @property
    def detection_mode(self) -> Optional[str]:
        return self._get_attr("detectionMode")

    @detection_mode.setter
    def detection_mode(self, value: Optional[DetectionMode | str]):
        if isinstance(value, DetectionMode):
            v = value.value
        else:
            v = _norm_str(value)
        if v is not None:
            v = _ensure_enum_member(v, DetectionMode)
        self._set_attr("detectionMode", v)

    @property
    def formats(self) -> Optional[List[str]]:
        raw = self._get_attr("formats")
        if raw is None:
            return None
        try:
            return json.loads(raw)
        except Exception:
            return None

    @formats.setter
    def formats(self, value: Optional[Iterable[BarcodeFormat | str]]):
        if value is None:
            self._set_attr_json("formats", None)
            return
        out: List[str] = []
        for item in value:
            if isinstance(item, BarcodeFormat):
                s = item.value
            else:
                s = _norm_str(item)  # type: ignore[assignment]
            if s is None:
                continue
            if s == "qrcode":
                s = "qr"
            if s == BarcodeFormat.ALL.value:
                out = [BarcodeFormat.ALL.value]
                break
            _ensure_enum_member(s, BarcodeFormat)
            out.append(s)
        self._set_attr_json("formats", out)

    @property
    def torch(self) -> Optional[bool]:
        return self._get_attr("torch", data_type="bool")

    @torch.setter
    def torch(self, value: Optional[bool]):
        self._set_attr("torch", value)

    @property
    def auto_close(self) -> Optional[bool]:
        return self._get_attr("autoClose", data_type="bool")

    @auto_close.setter
    def auto_close(self, value: Optional[bool]):
        self._set_attr("autoClose", value)

    @property
    def overlay_title(self) -> Optional[str]:
        return self._get_attr("overlayTitle")

    @overlay_title.setter
    def overlay_title(self, value: Optional[str]):
        self._set_attr("overlayTitle", value)

    @property
    def on_result(self) -> OptionalControlEventCallable:
        return self._get_event_handler("result")

    @on_result.setter
    def on_result(self, handler: OptionalControlEventCallable):
        self._add_event_handler("result", handler)

    @property
    def on_closed(self) -> OptionalControlEventCallable:
        return self._get_event_handler("closed")

    @on_closed.setter
    def on_closed(self, handler: OptionalControlEventCallable):
        self._add_event_handler("closed", handler)

    def start(self):
        self.invoke_method("start", {}, wait_for_result=False)

    def stop(self):
        self.invoke_method("stop", {}, wait_for_result=False)

    def set_formats(self, *formats: BarcodeFormat | str):
        self.formats = list(formats)
