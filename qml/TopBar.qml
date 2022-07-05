import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: topBar

    property alias curTime: txtTime.text
    property alias curDate: txtDate.text

    function logout() {
        gCurrentUser = {}

        mainStack.pop(StackView.Immediate)
    }

    Row {
        id: rowLeft
        spacing: 30 * ui_RATIO
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left; leftMargin: 30 * ui_RATIO
        }

        Text {
            id: txtTitle
            anchors {
                verticalCenter: parent.verticalCenter
            }
            color: "#ffffff"
            font { pixelSize: 40 * ui_RATIO; bold: true }
            text: ConfigSettings.hospitalName
        }

        Text {
            id: txtDepartmentName
            anchors {
                verticalCenter: parent.verticalCenter
            }
            color: "#ffffff"
            font { pixelSize: 30 * ui_RATIO; bold: true }
            text: gDepartments[gCurrentRole] ? gDepartments[gCurrentRole].name : ""
        }
    }

    Row {
        id: rowRight
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right; rightMargin: 30 * ui_RATIO
        }
        spacing: 30 * ui_RATIO

        Column {
            //spacing: 10 * ui_RATIO

            Text {
                id: txtTime
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                color: "#ffffff"
                font { pixelSize: 30 * ui_RATIO }
            }

            Text {
                id: txtDate
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                color: "#ffffff"
                font { pixelSize: 18 * ui_RATIO }
            }
        }

        Button {
            id: buttonLogout
            anchors { top: parent.top; bottom: parent.bottom }
            width: 100 * ui_RATIO
            flat: true
            text: qsTr("退出")
            font { pixelSize: 30 * ui_RATIO }
            visible: gCurrentUser.id >= 0

            background: Rectangle {
                opacity: buttonLogout.pressed ? 0.8 : 1
                color: buttonLogout.pressed ? "#ffffff" : "transparent"
            }
            contentItem: Text {
                text: buttonLogout.text
                font: buttonLogout.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                logout();
            }
        }
    }

    Timer {
        id: timer
        running: true
        interval: 1000
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            var currentDate = new Date()

            curTime = Qt.formatTime(currentDate, "hh:mm:ss")
            curDate = Qt.formatDate(currentDate, "yyyy/MM/dd dddd")
        }
    }
}
