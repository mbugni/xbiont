"""Backend channel for the installer wizard.

Runs `xbiont run installer` requests as a subprocess and exposes the
backend JSON-lines protocol as Qt signals, so the frontend only deals
with typed events instead of process and protocol details.
"""

import json
from pathlib import Path

from qtpy import QtCore


class Backend(QtCore.QObject):
    message = QtCore.Signal(dict)
    diagnostic = QtCore.Signal(str)
    finished = QtCore.Signal(bool)

    def __init__(self, parent, step, values):
        super().__init__(parent)
        # stdout arrives in arbitrary chunks; partial lines are kept here
        # until a newline completes them
        self.buffer = b""
        self.valid = True
        self.received = False
        self.process = QtCore.QProcess(self)
        self.process.readyReadStandardOutput.connect(self.read)
        self.process.readyReadStandardError.connect(self.read_error)
        self.process.finished.connect(self.done)
        self.process.errorOccurred.connect(self.failed)
        self.step = step
        self.values = values

    def start(self):
        self.process.started.connect(self.send)
        # The xbiont launcher lives in bin/, next to libexec/
        launcher = Path(__file__).resolve().parents[5] / "bin/xbiont"
        # 'passthrough' keeps stdout a pure JSON channel; for the 'install'
        # request the backend re-executes itself through pkexec, so the
        # frontend never needs elevated privileges
        self.process.start(str(launcher), ["run", "installer", "X_ACTIONABLE_LOG_MODE=passthrough", f"X_INSTALL_REQUEST={self.step}"])

    def send(self):
        self.process.write(json.dumps(self.values).encode())
        self.process.closeWriteChannel()

    def read(self):
        self.buffer += bytes(self.process.readAllStandardOutput())
        while b"\n" in self.buffer:
            # '\n' cannot occur inside a multi-byte UTF-8 sequence, so each
            # extracted line is always a complete JSON document
            line, self.buffer = self.buffer.split(b"\n", 1)
            try:
                event = json.loads(line)
                if not isinstance(event, dict) or event.get("version") != 1 or event.get("type") not in ("targets", "boot", "plan", "progress", "command", "error", "completed"):
                    raise ValueError("Unsupported backend message")
                required = {
                    "targets": {"targets": list},
                    "boot": {"options": list, "default": str},
                    "plan": {"target": dict, "boot_mode": str, "execution": str, "layout": str, "warning": str, "warnings": list},
                    "progress": {"percent": int, "message": str},
                    "command": {"argv": list},
                    "error": {"code": str, "message": str},
                    "completed": {"success": bool, "execution": str},
                }
                if any(type(event.get(key)) is not kind for key, kind in required[event["type"]].items()):
                    raise ValueError("Incomplete backend message")
                if event["type"] == "progress" and not 0 <= event["percent"] <= 100:
                    raise ValueError("Invalid progress percentage")
                records = event["targets"] if event["type"] == "targets" else [event["target"]] if event["type"] == "plan" else []
                for record in records:
                    if not isinstance(record, dict) or any(not isinstance(record.get(key), str) for key in ("path", "kind", "description")) or type(record.get("size_bytes")) is not int:
                        raise ValueError("Invalid target record")
                if event["type"] == "boot" and (not event["options"] or any(not isinstance(option, dict) or any(not isinstance(option.get(key), str) for key in ("id", "label")) for option in event["options"]) or event["default"] not in [option["id"] for option in event["options"]]):
                    raise ValueError("Invalid boot options")
                if event["type"] == "command" and any(not isinstance(value, str) for value in event["argv"]):
                    raise ValueError("Invalid command arguments")
                if event["type"] == "plan" and any(not isinstance(value, str) for value in event["warnings"]):
                    raise ValueError("Invalid plan warnings")
                self.received = True
                # Protocol errors fail closed: malformed output must not
                # drive the UI into a bogus state
                if event["type"] == "error":
                    self.valid = False
                    self.diagnostic.emit(event["message"] + "\n")
                self.message.emit(event)
            except (ValueError, UnicodeError) as error:
                self.valid = False
                self.diagnostic.emit(f"Invalid backend output: {error}\n")

    def read_error(self):
        # stderr carries human diagnostics (dry-run log, command output),
        # shown verbatim in the details pane
        self.diagnostic.emit(bytes(self.process.readAllStandardError()).decode(errors="replace"))

    def done(self, code, status):
        # Drain whatever is left in the pipes before evaluating the outcome
        self.read()
        self.read_error()
        self.finished.emit(self.valid and self.received and not self.buffer and code == 0 and status == QtCore.QProcess.ExitStatus.NormalExit)

    def failed(self, error):
        if error == QtCore.QProcess.ProcessError.FailedToStart:
            self.diagnostic.emit(self.process.errorString() + "\n")
            self.finished.emit(False)
