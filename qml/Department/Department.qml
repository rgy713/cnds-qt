import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    id: departmentView
    color: "#f5f5f5"

    property var currentDate: new Date()

    Connections {
        target: swipePageLoader

        onIsCurrentChanged: {
            if (isCurrent) {
                refresh()
            }
        }
    }

    Connections {
        target: mainStack

        onPatientListChanged: {
            refresh()
        }
    }

    Component.onCompleted: {
        refresh()
    }

    function refresh() {
        gPatientList = DBManager.getPatientList(gCurrentRole)
    }

    StackView {
        id: departmentStackView
        anchors.fill: parent
        initialItem: "qrc:/qml/Department/PatientList.qml"

        pushEnter: Transition {
          PropertyAnimation {
              property: "opacity"
              from: 0
              to:1
              duration: 200
          }
        }
        pushExit: Transition {
          PropertyAnimation {
              property: "opacity"
              from: 1
              to:0
              duration: 200
          }
        }
        popEnter: Transition {
          PropertyAnimation {
              property: "opacity"
              from: 0
              to:1
              duration: 200
          }
        }
        popExit: Transition {
          PropertyAnimation {
              property: "opacity"
              from: 1
              to:0
              duration: 200
          }
        }
    }
}
