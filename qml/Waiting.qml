import QtQuick 2.7
import QtQuick.Controls 2.0

MouseArea {
    id: waiting
    z: 1000
    visible: running
    scrollGestureEnabled: false
    propagateComposedEvents: true
    preventStealing: true
    hoverEnabled: true

    onPositionChanged: {
        mouse.accepted = true
    }

    onClicked: {
        mouse.accepted = true
    }

    property alias running: busyIndicator.playing

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        opacity: 0.5
    }

    AnimatedImage {
        id: busyIndicator
        anchors {
            centerIn: parent
        }
        playing: false
        width: 64 * ui_RATIO; height: 64 * ui_RATIO
        source: "qrc:/images/loading.gif"
    }
}
