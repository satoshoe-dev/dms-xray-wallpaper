// Defaults here must match XrayDaemon.qml: until a value is saved, the daemon
// uses its own fallback.

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modals.FileBrowser
import qs.Services
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "xrayWallpaper"

    readonly property var _settings: SettingsData.pluginSettings
    function cfg(key, fallback) {
        root._settings;
        return SettingsData.getPluginSetting("xrayWallpaper", key, fallback);
    }

    // Same check as the daemon: does the running niri know the pointer stream?
    // The first reply line is {"Ok": ...} or {"Err": ...}; after it the probe
    // disconnects again.
    property bool streamSupported: false
    property bool streamProbed: false
    Socket {
        path: Quickshell.env("NIRI_SOCKET") || ""
        connected: CompositorService.isNiri && path !== "" && !root.streamProbed

        parser: SplitParser {
            splitMarker: "\n"

            onRead: line => {
                try {
                    root.streamSupported = JSON.parse(line).Ok !== undefined;
                } catch (e) {}
                root.streamProbed = true;
            }
        }

        onConnectedChanged: {
            if (connected)
                write("\"PointerStream\"\n");
        }
    }

    ToggleSetting {
        id: enableToggle
        settingKey: "on"
        label: I18n.trFor("xrayWallpaper", "Show the second layer")
        description: I18n.trFor("xrayWallpaper", "Two wallpaper layers with a soft hole around the pointer. The hole shows the layer below.")
        defaultValue: true
    }

    Column {
        width: parent ? parent.width : implicitWidth
        spacing: Theme.spacingXS
        visible: enableToggle.value

        StyledText {
            text: I18n.trFor("xrayWallpaper", "Second image")
            color: Theme.surfaceText
            font.pixelSize: Theme.fontSizeMedium
        }

        StyledText {
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.cfg("image", "") || I18n.trFor("xrayWallpaper", "No image chosen yet.")
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
        }

        Row {
            spacing: Theme.spacingS

            DankButton {
                text: I18n.trFor("xrayWallpaper", "Choose image")
                buttonHeight: 36
                onClicked: imageBrowser.open()
            }

            DankButton {
                text: I18n.trFor("xrayWallpaper", "Remove")
                buttonHeight: 36
                enabled: root.cfg("image", "") !== ""
                opacity: enabled ? 1 : 0.5
                onClicked: SettingsData.setPluginSetting("xrayWallpaper", "image", "")
            }
        }
    }

    FileBrowserModal {
        id: imageBrowser
        browserTitle: I18n.trFor("xrayWallpaper", "Choose the second wallpaper")
        browserIcon: "image"
        browserType: "image"
        showHiddenFiles: false
        fileExtensions: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp"]
        onFileSelected: path => SettingsData.setPluginSetting("xrayWallpaper", "image", String(path).replace(/^file:\/\//, ""))
    }

    ToggleSetting {
        visible: enableToggle.value
        settingKey: "imageOnTop"
        label: I18n.trFor("xrayWallpaper", "Second image on top")
        description: I18n.trFor("xrayWallpaper", "Off: your wallpaper stays on top and the hole shows the second image. On: the other way round.")
        defaultValue: false
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "radius"
        label: I18n.trFor("xrayWallpaper", "Hole size")
        defaultValue: 260
        minimum: 20
        maximum: 1200
        unit: "px"
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "softness"
        label: I18n.trFor("xrayWallpaper", "Soft edge")
        description: I18n.trFor("xrayWallpaper", "How wide the transition between the two layers is.")
        defaultValue: 90
        minimum: 1
        maximum: 600
        unit: "px"
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "ringWidth"
        label: I18n.trFor("xrayWallpaper", "Glowing ring")
        description: I18n.trFor("xrayWallpaper", "A ring of light along the edge of the hole. 0 leaves it out.")
        defaultValue: 0
        minimum: 0
        maximum: 200
        unit: "px"
    }

    SelectionSetting {
        visible: enableToggle.value && root.cfg("ringWidth", 0) > 0
        settingKey: "ringColor"
        label: I18n.trFor("xrayWallpaper", "Ring color")
        defaultValue: "accent"
        options: [
            {
                label: I18n.trFor("xrayWallpaper", "Accent"),
                value: "accent"
            },
            {
                label: I18n.trFor("xrayWallpaper", "Text color"),
                value: "text"
            }
        ]
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "topOpacity"
        label: I18n.trFor("xrayWallpaper", "Upper layer opacity")
        description: I18n.trFor("xrayWallpaper", "100 keeps the upper layer closed, so the picture shows in the hole alone. Lower values let it through everywhere.")
        defaultValue: 100
        minimum: 0
        maximum: 100
        unit: "%"
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "dimTop"
        label: I18n.trFor("xrayWallpaper", "Darken the upper layer")
        defaultValue: 0
        minimum: 0
        maximum: 90
        unit: "%"
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "dimBottom"
        label: I18n.trFor("xrayWallpaper", "Darken the layer below")
        defaultValue: 0
        minimum: 0
        maximum: 90
        unit: "%"
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "followSpeed"
        label: I18n.trFor("xrayWallpaper", "Follow speed")
        description: I18n.trFor("xrayWallpaper", "Pixels per second. Lower values let the hole glide after the pointer.")
        defaultValue: 4000
        minimum: 200
        maximum: 20000
    }

    ToggleSetting {
        visible: enableToggle.value
        settingKey: "followOnDesktop"
        label: I18n.trFor("xrayWallpaper", "Follow on the desktop")
        description: I18n.trFor("xrayWallpaper", "The hole follows the pointer while no window is under it. The sensor sits below the desktop widgets, so they keep their clicks.")
        defaultValue: true
    }

    StyledText {
        visible: enableToggle.value
        width: parent ? parent.width : implicitWidth
        wrapMode: Text.WordWrap
        text: I18n.trFor("xrayWallpaper", "Over a window the pointer belongs to that window. The peek mode puts a round opening above the windows instead. Put it on a key as a switch with 'dms ipc call xray peek toggle', or to show while the key is held with 'dms ipc call xray hold'.")
        color: Theme.surfaceVariantText
        font.pixelSize: Theme.fontSizeSmall
    }

    ToggleSetting {
        visible: enableToggle.value && CompositorService.isNiri && root.streamSupported
        settingKey: "followEverywhere"
        label: I18n.trFor("xrayWallpaper", "Follow behind the windows")
        description: I18n.trFor("xrayWallpaper", "Takes the pointer position from niri instead of a sensor, so the hole also runs behind the windows, visible wherever they are see-through. Needs niri built with the pointer stream patch from the README. With a normal niri nothing changes.")
        defaultValue: false
    }

    StyledText {
        visible: enableToggle.value && CompositorService.isNiri
        width: parent ? parent.width : implicitWidth
        wrapMode: Text.WordWrap
        text: I18n.trFor("xrayWallpaper", "On niri the layers scroll away with the workspaces unless they sit in the backdrop. The README has the layer rule for the namespace xray-wallpaper.")
        color: Theme.surfaceVariantText
        font.pixelSize: Theme.fontSizeSmall
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "holdGrace"
        label: I18n.trFor("xrayWallpaper", "Hold mode: stay on after the key")
        description: I18n.trFor("xrayWallpaper", "The key repeat keeps the opening alive. This is how long it stays after the last repeat, so a slow key repeat needs a higher value.")
        defaultValue: 800
        minimum: 120
        maximum: 3000
        unit: "ms"
    }

    SliderSetting {
        visible: enableToggle.value
        settingKey: "peekSeconds"
        label: I18n.trFor("xrayWallpaper", "End peek mode after")
        description: I18n.trFor("xrayWallpaper", "A click also ends it. 0 keeps it on until you switch it off.")
        defaultValue: 20
        minimum: 0
        maximum: 600
        unit: "s"
    }
}
