import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

Item {
    id: settingAccounsView

    property var mUserRoleList: []

    function getUserRoleListFromLocal() {
        mUserRoleList = DBManager.getUserRoleList();
    }

    function collectFromServer() {
        main.showWaiting(true);

        var params = {};
        ServiceManager.request("getdepartmentlist", params);
    }

    Connections {
        target: swipePageLoader.isCurrent ? ServiceManager : null

        onResponse: {
            if (p_serviceName == "getdepartmentlist") {
                main.showWaiting(false);

                if (p_result.success) {
                    if (DBManager.setDepartmentList(p_result.result)) {
                        main.getDepartmentList()
                    }

                    main.showWaiting(true);

                    var params = {};
                    ServiceManager.request("getuserrolelist", params);
                }
                else {
                    messageDialog.title = qsTr("拉取用户权限")
                    messageDialog.text = p_result.message
                    messageDialog.open()
                }
            }
            else if (p_serviceName == "getuserrolelist") {
                main.showWaiting(false);

                if (p_result.success) {
                    if (DBManager.setUserRoleList(p_result.result)) {
                        getUserRoleListFromLocal();
                    }
                }
                else {
                    messageDialog.title = qsTr("拉取用户权限")
                    messageDialog.text = p_result.message
                    messageDialog.open()
                }
            }
        }
    }

    Component.onCompleted: {
        getUserRoleListFromLocal();
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("登录")
    }

    Button {
        id: buttonCollect
        text: qsTr("拉取用户权限")
        font { pixelSize: 25 * ui_RATIO; bold: true }
        anchors {
            left: parent.left; leftMargin: 50 * ui_RATIO
            top: parent.top; topMargin: 30 * ui_RATIO
        }
        width: 200 * ui_RATIO; height: 50 * ui_RATIO
        background: Rectangle {
            radius: 4 * ui_RATIO
            border { width: 1; color: "#7551AF" }
            color: buttonCollect.pressed ? "white" : "#7551AF"
        }
        contentItem: Text {
            text: buttonCollect.text
            font: buttonCollect.font
            color: buttonCollect.pressed ? "#7551AF" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        onClicked: {
            collectFromServer();
        }
    }

    Row {
        id: rowHeader
        anchors {
            left: buttonCollect.left; right: parent.right; rightMargin: 50 * ui_RATIO
            top: buttonCollect.bottom; topMargin: 30 * ui_RATIO
        }
        spacing: -1

        Repeater {
            model: listViewUserRole.colInfos

            Rectangle {
                color: "#f5f7f9"
                width: rowHeader.width * modelData.width
                height: 60 * ui_RATIO
                border { width: 1; color: "#e3e8ee" }

                Text {
                    id: txtHeaderLabel
                    anchors.centerIn: parent
                    font { pixelSize: 28 * ui_RATIO; bold: true }
                    color: "#657180"
                    text: modelData.label
                }
            }
        }
    }

    ScrollView {
        id: scrollView
        anchors {
            left: rowHeader.left; right: rowHeader.right
            top: rowHeader.bottom; topMargin: -1; bottom: parent.bottom; bottomMargin: 30 * ui_RATIO
        }
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        ListView {
            id: listViewUserRole
            width: scrollView.width - 10
            spacing: -1
            model: mUserRoleList

            property var colInfos: [
                { "label": qsTr("用户名"), "role": "name", "width": 0.2 },
                { "label": qsTr("登陆账号"), "role": "user_id", "width": 0.2 },
                { "label": qsTr("角色"), "role": "role_name", "width": 0.2 },
                { "label": qsTr("可访问科室"), "role": "role", "width": 0.2 },
                { "label": qsTr("状态"), "role": "is_active", "width": 0.2 }
            ]

            function modelValue(modelData, modelRole) {
                var delegateValue = modelData[modelRole]

                if (modelRole == "role") {
                    var delegateValueList = delegateValue.split(",")
                    return delegateValueList.length > 0 ? qsTr("全部科室") : gDepartments[delegateValue].name
                }
                else if (modelRole == "is_active") {
                    return delegateValue == 1 ? qsTr("有效") : qsTr("无效")
                }

                return delegateValue
            }

            delegate: Row {
                id: rowDelegate
                spacing: -1

                property var userData: modelData

                Repeater {
                    model: listViewUserRole.colInfos

                    Rectangle {
                        width: scrollView.width * modelData.width
                        height: 60 * ui_RATIO
                        border { width: 1; color: "#e3e8ee" }

                        Text {
                            id: txtDelegateLabel
                            anchors {
                                left: parent.left; right: parent.right; leftMargin: 5 * ui_RATIO; rightMargin: 5 * ui_RATIO
                                verticalCenter: parent.verticalCenter
                            }
                            font { pixelSize: 25 * ui_RATIO }
                            color: "#657180"
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: listViewUserRole.modelValue(userData, modelData.role)
                        }
                    }
                }
            }
        }
    }


}
