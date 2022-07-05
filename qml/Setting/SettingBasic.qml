import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

Item {
    id: settingBasicView

    Component.onCompleted: {
        if (gCurrentUser.role) {
            cboDepartment.currentIndex = gCurrentUser.role.split(",").indexOf(gCurrentRole)
        }
    }

    function basicSave() {
        ConfigSettings.hospitalName = inputHospitalName.text
        ConfigSettings.host = inputHostIp.text
        if (cboDepartment.currentIndex > -1) {
            gCurrentRole = gUserRoles[cboDepartment.currentIndex].id
        }

        messageDialog.title = qsTr("保存信息")
        messageDialog.text = qsTr("保存信息")
        messageDialog.open()
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("登录")
    }

    Rectangle {
        id: recInfos
        width: colInfos.width + 200 * ui_RATIO; height: colInfos.height + 100 * ui_RATIO
        border { width: 1; color: "#ccc" }
        anchors.centerIn: parent

        Column {
            id: colInfos
            anchors {
                centerIn: parent
            }
            spacing: 30 * ui_RATIO

            /*
            Row {
                spacing: 30 * ui_RATIO

                Text {
                    id: lblLogo
                    width: 200 * ui_RATIO
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 25 * ui_RATIO
                    color: "#657180"
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("LOGO :")
                }

                TextField {
                    id: inputLogo
                    width: 600 * ui_RATIO; height: 60 * ui_RATIO
                    font { pixelSize: 25 * ui_RATIO }
                    color: "#666"
                    KeyNavigation.tab: inputHospitalName

                    background: Rectangle {
                        radius: 4 * ui_RATIO
                        color: "#f5f5f5"
                        border { width: 1; color: "#ccc" }
                    }
                }
            }
            */

            Row {
                spacing: 30 * ui_RATIO

                Text {
                    id: lblHospitalName
                    width: 200 * ui_RATIO
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 25 * ui_RATIO
                    color: "#657180"
                    horizontalAlignment: Text.AlignRight
                    text:qsTr("医院名称 :")
                }

                TextField {
                    id: inputHospitalName
                    width: 600 * ui_RATIO; height: 60 * ui_RATIO
                    font { pixelSize: 25 * ui_RATIO }
                    color: "#666"
                    KeyNavigation.tab: cboDepartment
                    text: ConfigSettings.hospitalName

                    background: Rectangle {
                        radius: 4 * ui_RATIO
                        color: "#f5f5f5"
                        border { width: 1; color: "#ccc" }
                    }
                }
            }

            Row {
                spacing: 30 * ui_RATIO

                Text {
                    id: lblDepartmentName
                    width: 200 * ui_RATIO
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 25 * ui_RATIO
                    color: "#657180"
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("科室名称 :")
                }

                ComboBox {
                    id: cboDepartment
                    width: 600 * ui_RATIO; height: 60 * ui_RATIO
                    anchors.verticalCenter: parent.verticalCenter
                    font { pixelSize: mainFontSize }
                    textRole: "name"
                    model: gUserRoles


                    contentItem: Text {
                        leftPadding: 0
                        rightPadding: cboDepartment.indicator.width + cboDepartment.spacing

                        text: cboDepartment.displayText
                        font: cboDepartment.font
                        color: cboDepartment.visualFocus ? "#7551af" : "#657180"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        implicitWidth: 120
                        implicitHeight: 40
                        color: "#f5f5f5"
                        border.color: cboDepartment.visualFocus ? "#7551af" : "#ccc"
                        border.width: cboDepartment.visualFocus ? 2 : 1
                        radius: 2
                    }
                }
            }

            Row {
                spacing: 30 * ui_RATIO

                Text {
                    id: lblIp
                    width: 200 * ui_RATIO
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 25 * ui_RATIO
                    color: "#657180"
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("仪器IP地址 :")
                }

                TextField {
                    id: inputHostIp
                    width: 600 * ui_RATIO; height: 60 * ui_RATIO
                    font { pixelSize: 25 * ui_RATIO }
                    color: "#666"
                    placeholderText: qsTr("例: 192.168.1.107")
                    text: ConfigSettings.host

                    background: Rectangle {
                        radius: 4 * ui_RATIO
                        color: "#f5f5f5"
                        border { width: 1; color: "#ccc" }
                    }
                }
            }

            Button {
                id: buttonSave
                text: qsTr("保存信息")
                //enabled: txtUser.text.trim().length > 0 && txtPwd.text.trim().length > 0
                font { pixelSize: 25 * ui_RATIO; bold: true }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                width: 150 * ui_RATIO; height: 50 * ui_RATIO
                background: Rectangle {
                    radius: 4 * ui_RATIO
                    border { width: 1; color: "#7551AF" }
                    color: buttonSave.pressed ? "white" : "#7551AF"
                }
                contentItem: Text {
                    text: buttonSave.text
                    font: buttonSave.font
                    color: buttonSave.pressed ? "#7551AF" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: {
                    basicSave();
                }
            }

        }


    }
}
