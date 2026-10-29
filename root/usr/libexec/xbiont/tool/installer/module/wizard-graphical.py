import json
import sys
from pathlib import Path

from qtpy import QtCore, QtWidgets


class Backend(QtCore.QObject):
    message = QtCore.Signal(dict)
    diagnostic = QtCore.Signal(str)
    finished = QtCore.Signal(bool)

    def __init__(self, parent, step, values):
        super().__init__(parent)
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
        launcher = Path(__file__).resolve().parents[5] / "bin/xbiont"
        self.process.start(str(launcher), ["run", "installer", "X_ACTIONABLE_LOG_MODE=passthrough", f"X_INSTALL_REQUEST={self.step}"])

    def send(self):
        self.process.write(json.dumps(self.values).encode())
        self.process.closeWriteChannel()

    def read(self):
        self.buffer += bytes(self.process.readAllStandardOutput())
        while b"\n" in self.buffer:
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
                if event["type"] == "error":
                    self.valid = False
                    self.diagnostic.emit(event["message"] + "\n")
                self.message.emit(event)
            except (ValueError, UnicodeError) as error:
                self.valid = False
                self.diagnostic.emit(f"Invalid backend output: {error}\n")

    def read_error(self):
        self.diagnostic.emit(bytes(self.process.readAllStandardError()).decode(errors="replace"))

    def done(self, code, status):
        self.read()
        self.read_error()
        self.finished.emit(self.valid and self.received and not self.buffer and code == 0 and status == QtCore.QProcess.ExitStatus.NormalExit)

    def failed(self, error):
        if error == QtCore.QProcess.ProcessError.FailedToStart:
            self.diagnostic.emit(self.process.errorString() + "\n")
            self.finished.emit(False)


class Installer(QtWidgets.QWizard):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Xbiont Installer — Preview")
        self.resize(700, 425)
        self.setOption(QtWidgets.QWizard.WizardOption.NoBackButtonOnLastPage)
        self.running = False
        self.scan_process = None
        self.process = None

        target_page, layout = self.create_page("Installation target", "Dry-run preview: no changes will be made to your devices.")
        self.targets = QtWidgets.QTreeWidget()
        self.targets.setHeaderLabels(["Target", "Size", "Type", "Description"])
        self.targets.setRootIsDecorated(False)
        self.targets.setSelectionMode(QtWidgets.QAbstractItemView.SelectionMode.SingleSelection)
        self.targets.itemSelectionChanged.connect(target_page.completeChanged.emit)
        self.targets.itemSelectionChanged.connect(self.invalidate_plan)
        target_page.isComplete = lambda: bool(self.targets.selectedItems())
        layout.addWidget(self.targets)
        self.scan_status = QtWidgets.QLabel("Looking for devices…")
        layout.addWidget(self.scan_status)
        refresh = QtWidgets.QPushButton("Refresh devices")
        refresh.clicked.connect(self.scan)
        layout.addWidget(refresh)

        _, layout = self.create_page("Boot configuration", "Choose how the installed system would start.")
        self.boot = QtWidgets.QButtonGroup(self)
        boot_group = QtWidgets.QGroupBox("Bootloader type")
        boot_layout = QtWidgets.QVBoxLayout(boot_group)
        boot_layout.setSpacing(16)
        self.boot_layout = boot_layout
        boot_page = self.page(1)
        boot_page.isComplete = lambda: self.boot.checkedButton() is not None
        self.boot.buttonToggled.connect(lambda *_: boot_page.completeChanged.emit())
        self.boot.buttonToggled.connect(lambda *_: self.invalidate_plan())
        layout.addWidget(boot_group)
        layout.addStretch()

        self.review_page, layout = self.create_page("Review installation", "Check your choices before starting the preview.")
        self.review_values = {}
        for title, fields in (
            ("Storage", ("Target", "Layout")),
            ("Installation", ("Boot mode", "Execution")),
        ):
            group = QtWidgets.QGroupBox(title)
            rows = QtWidgets.QFormLayout(group) if title == "Storage" else QtWidgets.QHBoxLayout(group)
            if isinstance(rows, QtWidgets.QFormLayout):
                rows.setLabelAlignment(QtCore.Qt.AlignmentFlag.AlignRight | QtCore.Qt.AlignmentFlag.AlignVCenter)
                rows.setFieldGrowthPolicy(QtWidgets.QFormLayout.FieldGrowthPolicy.AllNonFixedFieldsGrow)
                rows.setVerticalSpacing(6)
            for field in fields:
                value = QtWidgets.QLabel()
                value.setTextFormat(QtCore.Qt.TextFormat.PlainText)
                value.setTextInteractionFlags(QtCore.Qt.TextInteractionFlag.TextSelectableByMouse)
                value.setWordWrap(True)
                value.setAccessibleName(field)
                self.review_values[field] = value
                if isinstance(rows, QtWidgets.QFormLayout):
                    rows.addRow(f"{field}:", value)
                else:
                    rows.addWidget(value, 1)
            layout.addWidget(group)
        self.review_warning = QtWidgets.QLabel()
        self.review_warning.setTextFormat(QtCore.Qt.TextFormat.PlainText)
        self.review_warning.setWordWrap(True)
        layout.addWidget(self.review_warning)
        notice = QtWidgets.QLabel("Dry-run preview only. No installation changes will be made.")
        notice.setWordWrap(True)
        layout.addWidget(notice)
        layout.addStretch()
        self.review_page.setCommitPage(True)
        self.setButtonText(QtWidgets.QWizard.WizardButton.CommitButton, "Start dry run")

        self.progress_page, layout = self.create_page("Installation preview", "Commands are recorded, not executed. No authorization is requested.")
        self.status = QtWidgets.QLabel("Ready")
        self.status.setWordWrap(True)
        layout.addWidget(self.status)
        self.progress = QtWidgets.QProgressBar()
        layout.addWidget(self.progress)
        self.details_toggle = QtWidgets.QToolButton()
        self.details_toggle.setText("Show installation log")
        self.details_toggle.setCheckable(True)
        self.details_toggle.setToolButtonStyle(QtCore.Qt.ToolButtonStyle.ToolButtonTextBesideIcon)
        self.details_toggle.setArrowType(QtCore.Qt.ArrowType.RightArrow)
        layout.addWidget(self.details_toggle)
        self.details = QtWidgets.QPlainTextEdit()
        self.details.setReadOnly(True)
        self.details.setPlaceholderText("Dry-run command log")
        self.details.setVisible(False)
        self.details_toggle.toggled.connect(self.details.setVisible)
        self.details_toggle.toggled.connect(lambda expanded: self.details_toggle.setArrowType(QtCore.Qt.ArrowType.DownArrow if expanded else QtCore.Qt.ArrowType.RightArrow))
        self.details_toggle.toggled.connect(lambda expanded: self.details_toggle.setText("Hide installation log" if expanded else "Show installation log"))
        layout.addWidget(self.details)
        self.progress_page.isComplete = lambda: not self.running
        self.plan = None
        self.plan_generation = 0
        self.review_page.isComplete = lambda: self.plan is not None
        self.currentIdChanged.connect(self.enter_page)
        self.scan()
        self.boot_request = Backend(self, "boot", {})
        self.boot_request.message.connect(self.boot_options)
        self.boot_request.diagnostic.connect(self.log_text)
        self.boot_request.finished.connect(lambda ok: self.scan_status.setText("Boot discovery failed; see diagnostics.") if not ok else None)
        self.boot_request.start()

    def create_page(self, title, subtitle):
        page = QtWidgets.QWizardPage()
        page.setTitle(title)
        page.setSubTitle(subtitle)
        layout = QtWidgets.QVBoxLayout(page)
        self.addPage(page)
        return page, layout

    def scan(self):
        if self.scan_process and self.scan_process.process.state() != QtCore.QProcess.ProcessState.NotRunning:
            return
        self.targets.clear()
        self.scan_status.setText("Looking for devices…")
        self.scan_process = Backend(self, "partition", {})
        self.scan_process.message.connect(self.scanned)
        self.scan_process.diagnostic.connect(self.log_text)
        self.scan_process.finished.connect(lambda ok: self.scan_status.setText("Device discovery failed; see diagnostics.") if not ok else None)
        self.scan_process.start()

    def scanned(self, event):
        if event["type"] != "targets":
            return
        try:
            for device in event["targets"]:
                size = f"{int(device['size_bytes']) / (1024 ** 3):.1f} GiB"
                item = QtWidgets.QTreeWidgetItem([device["path"], size, device.get("filesystem") or device["kind"], device["description"]])
                self.targets.addTopLevelItem(item)
            self.targets.resizeColumnToContents(0)
            self.scan_status.setText("Select a disk or an unmounted partition." if self.targets.topLevelItemCount() else "No eligible devices found.")
        except (ValueError, KeyError, TypeError) as error:
            self.scan_status.setText(f"Unable to read device information: {error}")

    def boot_options(self, event):
        if event["type"] != "boot":
            return
        for option in event["options"]:
            button = QtWidgets.QRadioButton(option["label"])
            button.setProperty("boot_mode", option["id"])
            self.boot.addButton(button)
            self.boot_layout.addWidget(button)
            button.setChecked(option["id"] == event["default"])

    def invalidate_plan(self):
        if hasattr(self, "plan_generation"):
            self.plan_generation += 1
            self.plan = None
            self.review_page.completeChanged.emit()

    def selections(self):
        return {"target": self.targets.selectedItems()[0].text(0), "boot_mode": self.boot.checkedButton().property("boot_mode"), "execution": "dryrun"}

    def log_text(self, text):
        self.details.insertPlainText(text)
        sys.stderr.write(text)
        sys.stderr.flush()

    def enter_page(self, _page_id):
        page = self.currentPage()
        if page is self.review_page:
            self.invalidate_plan()
            generation = self.plan_generation
            self.review_warning.setText("Validating selections…")
            self.review_request = Backend(self, "summary", self.selections())
            self.review_request.message.connect(lambda event: self.show_plan(event, generation))
            self.review_request.diagnostic.connect(self.log_text)
            self.review_request.finished.connect(lambda ok: self.review_failed(generation) if not ok else None)
            self.review_request.start()
        elif page is self.progress_page:
            self.start_preview()
        else:
            self.invalidate_plan()

    def review_failed(self, generation):
        if generation == self.plan_generation:
            self.plan = None
            self.review_warning.setText("Validation failed. Go back and refresh your choices; see diagnostics.")
            self.review_page.completeChanged.emit()

    def show_plan(self, event, generation):
        if generation != self.plan_generation:
            return
        if event["type"] == "error":
            self.review_warning.setText(event["message"])
            return
        if event["type"] != "plan":
            return
        self.plan = event
        target = event["target"]
        values = {"Target": f"{target['path']} ({target['size_bytes'] / (1024 ** 3):.1f} GiB)", "Layout": event["layout"], "Boot mode": f"Boot mode: {event['boot_mode']}", "Execution": f"Execution: {event['execution']}"}
        for field, value in values.items():
            self.review_values[field].setText(value)
        self.review_warning.setText("\n".join([event["warning"]] + event["warnings"]))
        self.review_page.completeChanged.emit()

    def start_preview(self):
        self.running = True
        self.progress_page.completeChanged.emit()
        self.button(QtWidgets.QWizard.WizardButton.CancelButton).setEnabled(False)
        self.completed = False
        self.process = Backend(self, "install", {"target": self.plan["target"]["path"], "boot_mode": self.plan["boot_mode"], "execution": "dryrun"})
        self.process.message.connect(self.read_progress)
        self.process.diagnostic.connect(self.log_text)
        self.process.finished.connect(self.finished_preview)
        self.process.start()

    def read_progress(self, event):
        if event["type"] == "progress":
            self.progress.setValue(event["percent"])
            self.status.setText(event["message"])
        elif event["type"] == "command":
            self.details.appendPlainText(json.dumps(event["argv"], ensure_ascii=False))
        elif event["type"] == "error":
            self.log_text(event["message"] + "\n")
        elif event["type"] == "completed":
            self.completed = event.get("success") is True and event.get("execution") == "dryrun"

    def finished_preview(self, success):
        self.running = False
        success = success and self.completed
        self.status.setText("Dry run completed. No installation changes were made." if success else "Preview failed. Review the command log for details.")
        if success:
            self.progress.setValue(100)
        self.progress_page.completeChanged.emit()
        self.button(QtWidgets.QWizard.WizardButton.CancelButton).setEnabled(True)

    def reject(self):
        if not self.running:
            super().reject()


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    app.setApplicationName("Xbiont Installer")
    wizard = Installer()
    wizard.show()
    sys.exit(app.exec())
