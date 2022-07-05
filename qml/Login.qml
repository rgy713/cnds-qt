import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

MouseArea {
    id: loginView

    onClicked: {
        loginView.forceActiveFocus();
    }

    function login() {
        if (!buttonLogin.enabled)
            return

        gCurrentUser = DBManager.login(txtUser.text.trim(), txtPwd.text.trim());
        if (gCurrentUser.id >= 0) {
            mainStack.push("qrc:/qml/MainStack.qml", StackView.Immediate)
        }
        else {
            messageDialog.text = qsTr("登录失败");
            messageDialog.open();
        }
    }

    Keys.onReturnPressed: {
        login()
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("登录")
    }

    Column {
        id: colTitle
        spacing: 40 * ui_RATIO

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: colLoginInfos.top; bottomMargin: 50 * ui_RATIO
        }

        Text {
            id: txtTitle
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            font { pixelSize: 60 * ui_RATIO; bold: true }
            text: qsTr("NRS-2002 筛查系统")
        }

        Text {
            id: txtVersion
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            font { pixelSize: 40 * ui_RATIO; bold: true }
            text: qsTr("V1.0")
        }
    }

    Column {
        id: colLoginInfos
        anchors {
            centerIn: parent
            verticalCenterOffset: 20 * ui_RATIO
        }
        width: parent.width * 0.37
        spacing: 24 * ui_RATIO

        Rectangle {
            id: layoutUser
            anchors {
                left: parent.left; right: parent.right;
            }
            height: 64 * ui_RATIO; radius: 10
            color: "#00000000"
            border { color: "#ffffff"; width: 1 }

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "#c47cf4"; opacity: 0.1
            }

            Image {
                id: imgUser
                anchors {
                    left: parent.left; leftMargin: 10 * ui_RATIO
                    verticalCenter: parent.verticalCenter
                }
                width: 40 * ui_RATIO; height: width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/login-user.png"
            }

            TextField {
                id: txtUser
                anchors {
                    left: imgUser.right; leftMargin: 20 * ui_RATIO; right: parent.right
                    top: parent.top; bottom: parent.bottom
                }
                font { pixelSize: 30 * ui_RATIO }
                placeholderText: qsTr("ID号")
                color: "#ffffff"
                text: "111"

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: "transparent"
                }
            }
        }

        Rectangle {
            id: layoutPwd
            anchors {
                left: parent.left; right: parent.right
            }
            height: 64 * ui_RATIO; radius: 10
            color: "#00000000"
            border { color: "#ffffff"; width: 1 }

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "#c47cf4"; opacity: 0.1
            }

            Image {
                id: imgPwd
                anchors {
                    left: parent.left; leftMargin: 10 * ui_RATIO
                    verticalCenter: parent.verticalCenter
                }
                width: 40 * ui_RATIO; height: width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/login-key.png"
            }

            TextField {
                id: txtPwd
                anchors {
                    left: imgPwd.right; leftMargin: 20 * ui_RATIO; right: parent.right
                    top: parent.top; bottom: parent.bottom
                }
                font { pixelSize: 30 * ui_RATIO }
                echoMode: TextInput.Password
                placeholderText: qsTr("密码")
                color: "#ffffff"
                text: "111"

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: "transparent"
                }
            }
        }
    }

    Button {
        id: buttonLogin
        text: qsTr("登录")
        enabled: txtUser.text.trim().length > 0 && txtPwd.text.trim().length > 0
        font { pixelSize: 35 * ui_RATIO; bold: true }
        anchors {
            top: colLoginInfos.bottom; topMargin: 20 * ui_RATIO
            left: colLoginInfos.left; right: colLoginInfos.right
        }

        height: 60 * ui_RATIO
        background: Rectangle {
            opacity: enabled ? buttonLogin.pressed ? 0.8 : 0.3 : 0.1
            color: "#ffffff"
        }
        contentItem: Text {
            text: buttonLogin.text
            font: buttonLogin.font
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        onClicked: {
            login()
        }
    }

    Image {
        id: imgBottom
        source: "qrc:/images/login-foot.png"
        anchors {
            left: parent.left; right: parent.right; bottom: parent.bottom
        }
        height: 90 * ui_RATIO
        fillMode: Image.Stretch

        Text {
            id: txtCopyright
            anchors {
                left: parent.left; leftMargin: 20 * ui_RATIO
                verticalCenter: parent.verticalCenter
            }
            color: "#ffffff"
            font { pixelSize: 20 * ui_RATIO }
            text: qsTr("Copyright©2020 Ainst All Rights Reserved")
        }
    }
}
