// Xray wallpaper: a second picture behind the wallpaper, with a hole around the
// pointer that lets it through.
//
// The plugin draws its picture on a see-through surface above the DMS
// wallpaper: inside the hole, or everywhere but the hole when the picture is
// the upper layer. What it does not draw stays clear, so the wallpaper, its
// transitions, desktop widgets and other background plugins keep working.
//
// Wayland delivers pointer motion only to the surface that has the pointer, so
// there are two ways to follow it:
//   desktop: a sensor surface on the background layer, below the layer that
//            holds desktop widgets, so widgets keep their clicks. It only sees
//            the pointer while no window is under it.
//   peek:    a sensor on the overlay layer, switched on by IPC. It follows the
//            pointer everywhere, including over windows, and takes clicks while
//            it is on.
//
// On niri, background surfaces move with the workspaces unless they sit in the
// backdrop; the README has the layer rule for the namespaces used here.

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property var popoutService: null

    readonly property var _settings: SettingsData.pluginSettings
    function cfg(key, fallback) {
        return SettingsData.getPluginSetting("xrayWallpaper", key, fallback);
    }

    readonly property bool enabled: {
        root._settings;
        return cfg("on", true);
    }
    // The image of the plugin, and whether it is the lower or the upper layer
    readonly property string imagePath: {
        root._settings;
        const p = cfg("image", "");
        return p.startsWith("file://") ? decodeURIComponent(p.substring(7)) : p;
    }
    readonly property bool imageOnTop: {
        root._settings;
        return cfg("imageOnTop", false);
    }
    readonly property int radius: {
        root._settings;
        return Math.max(20, Math.min(1200, cfg("radius", 260)));
    }
    readonly property int softness: {
        root._settings;
        return Math.max(1, Math.min(600, cfg("softness", 90)));
    }
    readonly property int ringWidth: {
        root._settings;
        return Math.max(0, Math.min(200, cfg("ringWidth", 0)));
    }
    readonly property string ringColorChoice: {
        root._settings;
        return cfg("ringColor", "accent");
    }
    readonly property int dimTop: {
        root._settings;
        return Math.max(0, Math.min(90, cfg("dimTop", 0)));
    }
    readonly property int dimBottom: {
        root._settings;
        return Math.max(0, Math.min(90, cfg("dimBottom", 0)));
    }
    // How fast the hole follows the pointer, in pixels per second
    readonly property int followSpeed: {
        root._settings;
        return Math.max(200, Math.min(20000, cfg("followSpeed", 4000)));
    }
    readonly property bool followOnDesktop: {
        root._settings;
        return cfg("followOnDesktop", true);
    }
    // Ends the peek mode by itself after this many seconds, 0 keeps it on
    readonly property int peekSeconds: {
        root._settings;
        return Math.max(0, Math.min(600, cfg("peekSeconds", 20)));
    }
    // How much of the upper layer stays: 100 covers, lower values let the other
    // picture through everywhere, not only in the hole
    readonly property int topOpacity: {
        root._settings;
        return Math.max(0, Math.min(100, cfg("topOpacity", 100)));
    }
    // How long the peek stays on after the last `peek hold`, in milliseconds
    readonly property int holdGrace: {
        root._settings;
        return Math.max(120, Math.min(3000, cfg("holdGrace", 800)));
    }

    readonly property bool usable: root.enabled && root.imagePath !== "" && !root.imagePath.startsWith("#")

    property bool peeking: false
    // The hole is open while the pointer is being followed
    property bool holeOpen: false
    property real pointerX: 0
    property real pointerY: 0

    // While the hole is closed the position jumps, so it opens where the pointer
    // is instead of gliding in from the last spot.
    property bool snapping: false

    function setPointer(x, y) {
        root.snapping = !root.holeOpen;
        root.pointerX = x;
        root.pointerY = y;
        root.holeOpen = true;
        root.snapping = false;
    }

    // Both surfaces read the same glided position, so the hole and the lens
    // stay in step when the peek mode switches on.
    property real holeX: root.pointerX
    property real holeY: root.pointerY
    property real openAmount: root.holeOpen ? 1 : 0

    Behavior on holeX {
        enabled: !root.snapping
        SmoothedAnimation {
            velocity: root.followSpeed
        }
    }
    Behavior on holeY {
        enabled: !root.snapping
        SmoothedAnimation {
            velocity: root.followSpeed
        }
    }
    Behavior on openAmount {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: holdTimer
        interval: root.holdGrace
        onTriggered: root.peeking = false
    }

    Timer {
        id: peekTimeout
        interval: Math.max(1, root.peekSeconds) * 1000
        onTriggered: root.peeking = false
    }

    onPeekingChanged: {
        if (root.peeking && root.peekSeconds > 0)
            peekTimeout.restart();
        else
            peekTimeout.stop();
        if (!root.peeking) {
            root.holeOpen = false;
            holdTimer.stop();
        }
    }

    // dms ipc call xray peek on|off|toggle
    IpcHandler {
        target: "xray"

        function peek(state: string): string {
            if (!root.usable)
                return "no second image set";
            root.peeking = state === "toggle" ? !root.peeking : (state === "on" || state === "true");
            return root.peeking ? "peeking" : "off";
        }

        // dms ipc call xray hold -- for a key held down. niri repeats the bind
        // while the key is down, and each repeat pushes the end a bit further.
        function hold(): string {
            if (!root.usable)
                return "no picture set";
            root.peeking = true;
            holdTimer.restart();
            return "holding";
        }

        // dms ipc call xray at <x> <y> -- puts the hole at a fixed spot, for
        // keybinds and scripts. The next pointer motion takes over again.
        function at(x: string, y: string): string {
            if (!root.usable)
                return "no second image set";
            root.setPointer(Number(x) || 0, Number(y) || 0);
            return "hole at " + root.pointerX + "," + root.pointerY;
        }

        function close(): string {
            root.holeOpen = false;
            return "closed";
        }

        // dms ipc call xray set <key> <value>
        function set(key: string, value: string): string {
            const allowed = ["on", "image", "imageOnTop", "radius", "softness", "ringWidth", "ringColor", "dimTop", "dimBottom", "followSpeed", "followOnDesktop", "peekSeconds", "topOpacity", "holdGrace"];
            if (allowed.indexOf(key) < 0)
                return "unknown key, allowed: " + allowed.join(", ");
            let v = value;
            if (value === "true" || value === "false")
                v = value === "true";
            else if (value !== "" && !isNaN(Number(value)) && key !== "image")
                v = Number(value);
            SettingsData.setPluginSetting("xrayWallpaper", key, v);
            return key + " = " + JSON.stringify(v);
        }

        function status(): string {
            return JSON.stringify({
                "enabled": root.enabled,
                "image": root.imagePath,
                "imageOnTop": root.imageOnTop,
                "peeking": root.peeking,
                "open": root.holeOpen
            });
        }
    }

    readonly property bool shown: root.usable && !(CompositorService.isNiri && NiriService.inOverview)

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: surface

            required property var modelData

            readonly property int fill: {
                const m = Theme.getFillMode(SessionData.getMonitorWallpaperFillMode(surface.modelData?.name ?? ""));
                if (m === Image.Stretch)
                    return 0;
                if (m === Image.PreserveAspectFit)
                    return 1;
                return 2;
            }

            screen: surface.modelData
            visible: root.shown
            color: "transparent"

            WlrLayershell.namespace: "xray-wallpaper"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            mask: Region {
                item: Item {}
            }

            XrayLayer {
                anchors.fill: parent
                ctl: root
                imagePath: root.imagePath
                fill: surface.fill
            }
        }
    }

    // Sensor on the desktop: background layer, so the surfaces that carry
    // desktop widgets (bottom layer) keep their clicks.
    Variants {
        model: root.followOnDesktop && root.usable ? Quickshell.screens : []

        delegate: PanelWindow {
            id: deskSensor

            required property var modelData

            screen: deskSensor.modelData
            color: "transparent"

            WlrLayershell.namespace: "xray-sensor"
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onPositionChanged: mouse => root.setPointer(mouse.x, mouse.y)
                onContainsMouseChanged: {
                    if (containsMouse)
                        root.setPointer(mouseX, mouseY);
                }
                onExited: {
                    if (!root.peeking)
                        root.holeOpen = false;
                }
            }
        }
    }

    // Peek mode: overlay layer, follows the pointer over windows as well
    Variants {
        model: root.peeking && root.usable ? Quickshell.screens : []

        delegate: PanelWindow {
            id: peekSensor

            required property var modelData

            screen: peekSensor.modelData
            color: "transparent"

            WlrLayershell.namespace: "xray-peek"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            readonly property int fill: {
                const m = Theme.getFillMode(SessionData.getMonitorWallpaperFillMode(peekSensor.modelData?.name ?? ""));
                if (m === Image.Stretch)
                    return 0;
                if (m === Image.PreserveAspectFit)
                    return 1;
                return 2;
            }

            // Above the windows the layer below shows through the hole alone,
            // the rest of the surface stays clear.
            XrayLayer {
                anchors.fill: parent
                ctl: root
                imagePath: root.imagePath
                fill: peekSensor.fill
                lensOnly: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.CrossCursor
                onPositionChanged: mouse => root.setPointer(mouse.x, mouse.y)
                onContainsMouseChanged: {
                    if (containsMouse)
                        root.setPointer(mouseX, mouseY);
                }
                // a click ends the peek instead of going to the window below
                onClicked: root.peeking = false
            }
        }
    }
}
