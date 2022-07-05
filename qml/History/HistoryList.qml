import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

Rectangle {
    id: historyListView
    color: "#f5f5f5"

    property string mSubmittedPatientId: ""

    function submit(patientId) {
        mSubmittedPatientId = patientId
        var result = DBManager.getNRS2002(patientId)

        var params = {
            "user_id": gCurrentUser.id,
            "data": "[%1]".arg(result)
        }

        main.showWaiting(true)
        ServiceManager.request("submitnrs2002", params)
    }

    Connections {
        target: swipePageLoader.isCurrent ? ServiceManager : null

        onResponse: {
            if (p_serviceName == "submitnrs2002") {
                main.showWaiting(false);

                if (p_result.success) {
                    DBManager.setSubmittedNRS2002(mSubmittedPatientId, true)
                    mainStack.historyListChanged()

                    messageDialog.title = qsTr("提交")
                    messageDialog.text = qsTr("提交成功")
                    messageDialog.open()
                }
                else {
                    messageDialog.title = qsTr("提交")
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
        id: rowHeader
        anchors {
            left: parent.left; leftMargin: 50 * ui_RATIO; right: parent.right; rightMargin: 50 * ui_RATIO
            top: parent.top; topMargin: 30 * ui_RATIO
        }
        spacing: -1

        Repeater {
            model: listViewPatient.colInfos

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
            id: listViewPatient
            width: scrollView.width - 10
            spacing: -1
            model: gHistoryList

            property var colInfos: [
                { "label": qsTr("患者编号"), "role": "id", "width": 0.1 },
                { "label": qsTr("姓名"), "role": "name", "width": 0.1 },
                { "label": qsTr("科室"), "role": "department_name", "width": 0.15 },
                { "label": qsTr("床号"), "role": "bed_code", "width": 0.1 },
                { "label": qsTr("筛查状态"), "role": "nrs2002", "width": 0.15 },
                { "label": qsTr("筛查时间"), "role": "therapy_start_time", "width": 0.1 },
                { "label": qsTr("是否推送"), "role": "submitted", "width": 0.1 },
                { "label": qsTr("筛查人员"), "role": "user_name", "width": 0.1 },
                { "label": qsTr("操作"), "role": "control", "width": 0.1 }
            ]

            function modelValue(modelData, modelRole) {
                var delegateValue = modelData[modelRole]

                if (modelRole == "therapy_start_time") {
                    return Qt.formatDate(new Date(delegateValue), "yyyy/MM/dd")
                }
                else if (modelRole == "submitted") {
                    return delegateValue == 1 ? qsTr("是") : qsTr("否")
                }

                return typeof delegateValue === "undefined" ? "" : delegateValue
            }

            delegate: Row {
                id: rowDelegate
                spacing: -1

                property var patientData: modelData

                Repeater {
                    model: listViewPatient.colInfos

                    Rectangle {
                        id: recDelegate
                        width: scrollView.width * modelData.width
                        height: 60 * ui_RATIO
                        border { width: 1; color: "#e3e8ee" }

                        Loader {
                            anchors {
                                left: parent.left; right: parent.right
                                leftMargin: modelData.role != "control" ? 5 * ui_RATIO : 20 * ui_RATIO;
                                rightMargin: modelData.role != "control" ? 5 * ui_RATIO : 20 * ui_RATIO
                                verticalCenter: parent.verticalCenter
                            }

                            property var rowInfo: rowDelegate.patientData
                            property var colInfo: modelData

                            sourceComponent: modelData.role != "control" ? txtComp :
                                            !rowDelegate.patientData.submitted ? buttonCmp : null
                        }
                    }
                }
            }
        }
    }

    Component {
        id: txtComp

        Text {
            id: txtDelegateLabel

            font { pixelSize: 25 * ui_RATIO }
            color: "#657180"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: listViewPatient.modelValue(rowInfo, colInfo.role)
        }
    }

    Component {
        id: buttonCmp

        Button {
            id: buttonDelegate
            text: qsTr("提交")
            font { pixelSize: 25 * ui_RATIO; bold: true }
            height: 40 * ui_RATIO
            background: Rectangle {
                radius: 4 * ui_RATIO
                border { width: 1; color: "#7551AF" }
                color: buttonDelegate.pressed ? "white" : "#7551AF"
            }
            contentItem: Text {
                text: buttonDelegate.text
                font: buttonDelegate.font
                color: buttonDelegate.pressed ? "#7551AF" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                submit(rowInfo.id)
            }
        }
    }
}
