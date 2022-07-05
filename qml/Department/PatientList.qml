import QtQuick 2.7

Item {
    id: patientListView

    function gotoNRS2002(patientInfo) {
        departmentStackView.push("qrc:/qml/Department/NRS2002.qml", { "mPatientInfo": patientInfo })
    }

    GridView {
        id: gridView
        model: gPatientList
        cellWidth: width / 5
        cellHeight: cellWidth * 250 / 300
        clip: true

        anchors {
            left: parent.left; leftMargin: 20 * ui_RATIO; right: parent.right; rightMargin:  20 * ui_RATIO; top: parent.top; bottom: parent.bottom
        }

        delegate: MouseArea {
            width: gridView.cellWidth; height: gridView.cellHeight

            onClicked: {
                gotoNRS2002(modelData)
            }

            Rectangle {
                radius: 10
                anchors {
                    fill: parent; margins: 20 * ui_RATIO
                }

                Item {
                    id: recTop
                    height: parent.height / 4
                    anchors {
                        left: parent.left; right: parent.right
                    }

                    Text {
                        id: txtNumber
                        anchors {
                            left: parent.left; leftMargin: 20 * ui_RATIO; verticalCenter: parent.verticalCenter
                        }
                        color: "#5356a5"
                        font { pixelSize: 27 * ui_RATIO; bold: true }
                        text: modelData.bed_code
                    }

                    Text {
                        id: txtSex
                        anchors {
                            right: parent.right; rightMargin: 20 * ui_RATIO; verticalCenter: parent.verticalCenter
                        }
                        color: "#333333"
                        font { pixelSize: 25 * ui_RATIO; bold: true }
                        text: ("%1 %2岁").arg(modelData.gender == 0 ? qsTr("男") : qsTr("女")).arg(modelData.age)
                    }

                    Rectangle {
                        anchors {
                            left: parent.left; right: parent.right; bottom: parent.bottom
                        }
                        height: 1
                        color: "#333333"
                    }
                }

                Text {
                    id: txtName
                    anchors.centerIn: parent
                    font { pixelSize: 30 * ui_RATIO; bold: true }
                    text: modelData.name
                }

                Item {
                    id: recBottom
                    height: parent.height / 4
                    anchors {
                        left: parent.left; right: parent.right; bottom: parent.bottom
                    }

                    Text {
                        id: txtStatus
                        anchors {
                            left: parent.left; leftMargin: 20 * ui_RATIO; verticalCenter: parent.verticalCenter
                        }
                        color: "#5356A5"
                        font { pixelSize: 25 * ui_RATIO; bold: true }
                        text: nrs2002 >= 3 || (nrs2002 < 3 && new Date(nrs2002) > currentDate) ? (nrs2002 >= 3 ? ("<font color=\"red\">" + nrs2002 + "分</font>") : nrs2002) :
                              nrs2002 < 3 && new Date(nrs2002) <= currentDate ? "<font color=\"red\">" + qsTr("应复查") + "</font>" :
                              qsTr("未筛查")

                        property real nrs2002: modelData.nrs2002
                    }

                    Text {
                        id: txtDesease
                        anchors {
                            right: parent.right; rightMargin: 20 * ui_RATIO; verticalCenter: parent.verticalCenter
                        }
                        color: "#ff0000"
                        font { pixelSize: 25 * ui_RATIO; bold: true }
                        text: qsTr("有风险")
                    }
                }
            }
        }
    }
}
