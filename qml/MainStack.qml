import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

Item {
    id: mainStack



    property var mMenuItems: [
        { "name": "Department", "label": qsTr("科室信息") },
        { "name": "History", "label": qsTr("历史记录") },
        { "name": "Setting", "label": qsTr("系统设置") }
    ]
    property var mMenuPages: gCurrentUser.id > 0 ? ["Department", "History", "Setting"] : ["Setting"]

    property alias mCurrentMenuIndex: swipeView.currentIndex
    property var mCurrentMenuName: mMenuPages[mCurrentMenuIndex]

    Component.onCompleted: {
        gUserRoles = []
        if (gCurrentUser.role) {
            var userRoles = gCurrentUser.role.split(",")
            gCurrentRole = userRoles[0]

            userRoles.forEach(function(role) {
                var department = gDepartments[role];
                if (department) {
                    gUserRoles.push(department)
                }
            })

            patientListChanged();
        }
    }

    function collect() {
        main.showWaiting(true);

        var params = { "department_list": "[" + gCurrentRole + "]" }
        ServiceManager.request("getpatientlist", params);
    }

    function submit() {
        var allResult = DBManager.getAllNRS2002(gCurrentUser.user_id);
        if (allResult.length > 0) {
            var params = {
                "user_id": gCurrentUser.id,
                "data": JSON.stringify(allResult)
            }

            main.showWaiting(true)
            ServiceManager.request("submitnrs2002all", params)
        }
    }

    signal patientListChanged();
    signal historyListChanged();

    Connections {
        target: ServiceManager

        onResponse: {
            if (p_serviceName == "getpatientlist") {
                main.showWaiting(false);

                if (p_result.success) {
                    if (DBManager.setPatientList(p_result.result)) {
                        patientListChanged();
                    }
                }
                else {
                    messageDialog.title = qsTr("一键拉取")
                    messageDialog.text = p_result.message
                    messageDialog.open()
                }
            }
            else if (p_serviceName == "submitnrs2002all") {
                main.showWaiting(false);

                if (p_result.success) {
                    DBManager.setAllSubmittedNRS2002(gCurrentUser.user_id, true)
                    historyListChanged()

                    messageDialog.title = qsTr("一键提交")
                    messageDialog.text = qsTr("提交成功")
                    messageDialog.open()
                }
                else {
                    messageDialog.title = qsTr("一键提交")
                    messageDialog.text = p_result.message
                    messageDialog.open()
                }
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("登录")
    }

    Row {
        id: rowControls
        spacing: 50 * ui_RATIO

        anchors {
            left: parent.left; leftMargin: 30 * ui_RATIO
        }

        Button {
            id: buttonCollect
            text: qsTr("一键拉取")
            font { pixelSize: 30 * ui_RATIO; bold: true }
            anchors {
                verticalCenter: parent.verticalCenter
            }
            enabled: gCurrentUser.id > 0

            width: 200 * ui_RATIO; height: 60 * ui_RATIO
            background: Rectangle {
                radius: 10 * ui_RATIO
                opacity: enabled ? buttonCollect.pressed ? 0.8 : 0.3 : 0.1
                color: "#ffffff"
            }
            contentItem: Text {
                text: buttonCollect.text
                font: buttonCollect.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                opacity: enabled ? 1 : 0.3
            }

            onClicked: {
                collect()
            }
        }

        Button {
            id: buttonSubmit
            text: qsTr("一键推送")
            font { pixelSize: 30 * ui_RATIO; bold: true }
            anchors {
                verticalCenter: parent.verticalCenter
            }
            enabled: gCurrentUser.id > 0

            width: 200 * ui_RATIO; height: 60 * ui_RATIO
            background: Rectangle {
                radius: 10 * ui_RATIO
                opacity: enabled ? buttonSubmit.pressed ? 0.8 : 0.3 : 0.1
                color: "#ffffff"
            }
            contentItem: Text {
                text: buttonSubmit.text
                font: buttonSubmit.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                opacity: enabled ? 1 : 0.3
            }

            onClicked: {
                submit()
            }
        }
    }

    Row {
        id: rowMenus
        anchors { left: rowControls.right; leftMargin: 50 * ui_RATIO; right: parent.right }

        Repeater {
            model: mMenuItems

            Item {
                id: menuItemDelegate
                width: rowMenus.width / mMenuItems.length
                height: 60 * ui_RATIO
                enabled: menuIndex > -1
                opacity: enabled ? 1 : 0.3

                property int menuIndex: mMenuPages.indexOf(modelData.name)

                Rectangle {
                    width: parent.width * 0.9; height: parent.height; radius: height / 2
                    anchors.centerIn: parent
                    color: modelData.name == mCurrentMenuName ? "#ffffff" : "transparent"
                    border { width: 1; color: "#ffffff" }

                    Text {
                        id: menuLabel
                        anchors.centerIn: parent
                        color: modelData.name == mCurrentMenuName ? "#524B9A" : "#ffffff"
                        font { pixelSize: 30 * ui_RATIO; bold: true }
                        text: modelData.label
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (modelData.name != mCurrentMenuName) {
                            mCurrentMenuIndex = menuItemDelegate.menuIndex
                        }
                    }
                }
            }
        }
    }

    SwipeView {
        id: swipeView

        anchors {
            left: parent.left; right: parent.right
            top: rowMenus.bottom; topMargin: 20 * ui_RATIO; bottom: parent.bottom
        }

        Repeater {
            model: mMenuPages

            Loader {
                id: swipePageLoader
                active: Math.abs(swipeView.currentIndex - index) <= 1
                source: "qrc:/qml/%1/%1.qml".arg(modelData)

                property bool isCurrent: SwipeView.isCurrentItem
            }
        }
    }
}
