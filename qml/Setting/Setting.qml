import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: settingView

    property var mMenuItems: [
        { "name": "SettingBasic", "label": qsTr("基本信息") },
        { "name": "SettingAccounts", "label": qsTr("权限管理") }
    ]

    property int mCurrentMenuIndex: 0
    property string mCurrentMenuName: mMenuItems[mCurrentMenuIndex].name

    function menuClick(menu) {

    }

    Rectangle {
        id: recLeftMenu
        width: 300 * ui_RATIO
        anchors {
            top: parent.top; bottom: parent.bottom
        }
        color: "#443c8d"

        Column {
            id: rowMenus
            anchors {
                left: parent.left; leftMargin: 20 * ui_RATIO; right: parent.right; rightMargin: 30 * ui_RATIO
                top: parent.top; topMargin: 80 * ui_RATIO
            }
            spacing: 45 * ui_RATIO

            Repeater {
                model: mMenuItems

                Button {
                    id: menuButton
                    text: modelData.label
                    font { pixelSize: 25 * ui_RATIO; bold: true }
                    width: rowMenus.width; height: 50 * ui_RATIO
                    enabled: !gCurrentUser.id || index == 0

                    background: Rectangle {
                        radius: 10 * ui_RATIO
                        border { width: 1; color: mCurrentMenuIndex == index ? "transparent" : "white" }
                        color: mCurrentMenuIndex == index ? "#A468F0" : "transparent"
                        opacity: enabled ? 1 : 0.3
                    }
                    contentItem: Text {
                        text: menuButton.text
                        font: menuButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        opacity: enabled ? 1 : 0.3
                    }

                    onClicked: {
                        mCurrentMenuIndex = index
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            top: parent.top; bottom: parent.bottom
            left: recLeftMenu.right; right: parent.right
        }
        color: "#f5f5f5"

        Loader {
            id: settingStackView
            anchors.fill: parent
            source: ("qrc:/qml/Setting/%1.qml").arg(mCurrentMenuName)
        }
    }
}
