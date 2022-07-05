import QtQuick 2.7

Item {
    id: historyView

    property var mSearchParams: new Object

    Connections {
        target: swipePageLoader

        onIsCurrentChanged: {
            if (isCurrent) {
                refresh()
            }
        }
    }

    Connections {
        target: swipePageLoader.isCurrent ? mainStack : null

        onPatientListChanged: {
            refresh()
        }
        onHistoryListChanged: {
            refresh()
        }
    }

    Component.onCompleted: {
        refresh()
    }

    function refresh() {
        gHistoryList = DBManager.searchPatientList(gCurrentRole, mSearchParams)
    }

    HistorySearchForm {
        id: historySearchFormView
        width: 300 * ui_RATIO
        anchors {
            top: parent.top; bottom: parent.bottom
        }
    }

    HistoryList {
        id: hitoryListView
        anchors {
            top: parent.top; bottom: parent.bottom
            left: historySearchFormView.right; right: parent.right
        }
    }
}
