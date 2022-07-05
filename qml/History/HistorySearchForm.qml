import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    id: historySearchFormView
    color: "#443c8d"

    function search() {
        mSearchParams["id"] = inputID.text
        mSearchParams["name"] = inputName.text

        historyView.refresh()
    }

    function reset() {
        mSearchParams = {}

        inputID.text = ""
        inputName.text = ""
    }

    Column {
        id: colInfos
        anchors {
            left: parent.left; leftMargin: 20 * ui_RATIO; right: parent.right; rightMargin: 30 * ui_RATIO
            top: parent.top; topMargin: 50 * ui_RATIO
        }
        spacing: 20 * ui_RATIO

        Column {
            spacing: 10 * ui_RATIO
            anchors {
                left: parent.left; right: parent.right
            }

            Text {
                id: lblID
                font.pixelSize: 25 * ui_RATIO
                color: "white"
                text: qsTr("患者编号")
            }

            TextField {
                id: inputID
                anchors {
                    left: parent.left; right: parent.right
                }
                height: 50 * ui_RATIO
                font { pixelSize: 25 * ui_RATIO }
                color: "#666"
                KeyNavigation.tab: inputName

                background: Rectangle {
                    radius: 4 * ui_RATIO
                    border { width: 1; color: "#ccc" }
                }
            }
        }

        Column {
            spacing: 10 * ui_RATIO
            anchors {
                left: parent.left; right: parent.right
            }

            Text {
                id: lblName
                font.pixelSize: 25 * ui_RATIO
                color: "white"
                text: qsTr("姓名")
            }

            TextField {
                id: inputName
                anchors {
                    left: parent.left; right: parent.right
                }
                height: 50 * ui_RATIO
                font { pixelSize: 25 * ui_RATIO }
                color: "#666"
                //KeyNavigation.tab: inputHospitalName

                background: Rectangle {
                    radius: 4 * ui_RATIO
                    border { width: 1; color: "#ccc" }
                }
            }
        }
    }

    Column {
        id: colControls
        anchors {
            left: parent.left; leftMargin: 20 * ui_RATIO; right: parent.right; rightMargin: 30 * ui_RATIO
            top: colInfos.bottom; topMargin: 30 * ui_RATIO
        }
        spacing: 20 * ui_RATIO

        Button {
            id: buttonSearch
            text: qsTr("查询")
            //enabled: txtUser.text.trim().length > 0 && txtPwd.text.trim().length > 0
            font { pixelSize: 25 * ui_RATIO }
            anchors {
                left: parent.left; right: parent.right
            }
            height: 50 * ui_RATIO
            background: Rectangle {
                radius: 4 * ui_RATIO
                border { width: 1; color: "#7551AF" }
                color: buttonSearch.pressed ? "white" : "#7551AF"
            }
            contentItem: Text {
                text: buttonSearch.text
                font: buttonSearch.font
                color: buttonSearch.pressed ? "#7551AF" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                search();
            }
        }

        Button {
            id: buttonReset
            text: qsTr("重置")
            //enabled: txtUser.text.trim().length > 0 && txtPwd.text.trim().length > 0
            font { pixelSize: 25 * ui_RATIO }
            anchors {
                left: parent.left; right: parent.right
            }
            height: 50 * ui_RATIO
            background: Rectangle {
                radius: 4 * ui_RATIO
                border { width: 1; color: "#7551AF" }
                color: buttonReset.pressed ? "white" : "#7551AF"
            }
            contentItem: Text {
                text: buttonReset.text
                font: buttonReset.font
                color: buttonReset.pressed ? "#7551AF" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            onClicked: {
                reset()
            }
        }
    }
}
