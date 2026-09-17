// One rendered surface of the xray wallpaper. Used twice: on the desktop, where
// the picture fills the hole around the pointer, and as a lens above the
// windows, where only the hole is drawn.
//
// The picture belongs to the surface. A texture cannot travel between windows,
// so a shared Image would leave the second surface black.

pragma ComponentBehavior: Bound

import QtQuick
import qs.Common

Item {
    id: layer

    required property var ctl
    required property string imagePath
    // 0 stretch, 1 fit, 2 crop, like the DMS wallpaper
    required property int fill
    property bool lensOnly: false

    readonly property bool ready: picture.status === Image.Ready

    Image {
        id: picture
        visible: false
        asynchronous: true
        cache: true
        smooth: true
        source: layer.imagePath === "" ? "" : "file://" + layer.imagePath
        sourceSize.width: 3840
    }

    ShaderEffect {
        anchors.fill: parent
        visible: layer.ready
        blending: true

        property var source: picture
        property real fillMode: layer.fill
        property real imageW: picture.implicitWidth
        property real imageH: picture.implicitHeight
        property real screenW: width
        property real screenH: height
        property real centerX: layer.ctl.holeX
        property real centerY: layer.ctl.holeY
        property real radius: layer.ctl.radius
        property real softness: layer.ctl.softness
        property real open: layer.ctl.openAmount
        property real ringWidth: layer.ctl.ringWidth
        property real dimTop: layer.ctl.dimTop / 100
        property real dimBottom: layer.ctl.dimBottom / 100
        property real topOpacity: layer.ctl.topOpacity / 100
        property real imageOnTop: layer.ctl.imageOnTop ? 1 : 0
        property real lens: layer.lensOnly ? 1 : 0
        property color ringColor: layer.ctl.ringColorChoice === "text" ? Theme.surfaceText : Theme.primary

        fragmentShader: Qt.resolvedUrl("shaders/xray.frag.qsb")
    }
}
