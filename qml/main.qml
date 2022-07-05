import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0

Window {
    id: main
    visible: true
    title: qsTr("NRS2002")

    width : mainWidth
    height: mainHeight
    flags: Qt.Window

    property real   designWidth          : 1920
    property real   designHeight         : 1080

    property real   mainWidth            : Screen.desktopAvailableWidth
    property real   mainHeight           : Screen.desktopAvailableHeight

    property real   hRatio               : width / designWidth
    property real   vRatio               : height / designHeight

    property real   ui_RATIO             : hRatio < vRatio ? hRatio : vRatio
    property real   ui_ppiRatio          : Math.min(1, (300/*Default PPI*/ / (Screen.pixelDensity * 25.4/*Inch*/)) / ui_RATIO)

    property real mainFontSize: 25 * ui_RATIO
    property real mainFontSize1: 28 * ui_RATIO
    property real mainFontSize2: 30 * ui_RATIO

    property var    gCurrentUser: new Object
    property string gCurrentRole: "0"
    property var    gUserRoles: []

    property var gDiseaseList: []
    property var gDepartmentList: []
    property var gDepartments: new Object

    property var gPatientList: []
    property var gHistoryList: []

    property int gScreeningTimeout: 7

    Component.onCompleted: {
        getDepartmentList()
        getDiseaseList()

    }

    function showWaiting(running) {
        waiting.running = running
    }

    function getDepartmentList() {
        gDepartmentList = DBManager.getDepartmentList();
        gDepartmentList.forEach(function(department){
            gDepartments[department.id + ""] = department
        })
    }

    function getDiseaseList() {
        gDiseaseList = DBManager.getDiseaseList();
    }

    Image {
        id: imgBackground
        anchors.fill: parent
        source: "qrc:/images/login-back.png"
    }

    TopBar {
        id: topBar
        anchors {
            top: parent.top; left: parent.left; right: parent.right
        }
        height: 150 * ui_RATIO
    }

    StackView {
        id: mainStack
        anchors {
            top: topBar.bottom; bottom: parent.bottom; left: parent.left; right: parent.right
        }
        initialItem: "qrc:/qml/Login.qml"
    }

    Waiting {
        id: waiting
        anchors.fill: parent
    }

    function getBMI(weight, height) {
        weight = weight ? weight : 0
        if (!height)
            return 0.0

        var value = weight / ((height/100) * (height/100))
        return value.toFixed(1)
    }

    function getWeightChange(lastWeight, nowWeight) {
        var _lastWeight = lastWeight ? lastWeight : 0
        var _nowWeight = nowWeight ? nowWeight : 0

        var value;
        value = _lastWeight ? (_nowWeight - _lastWeight) / _lastWeight *100 : 0
        return Number(value.toFixed(2))
    }

    function outDate(){
         return new Date(new Date().getTime() + 60 * 60 * 24 * gScreeningTimeout * 1000)
    }

    function getRealValue(value, defaultValue) {
        var __defaultValue = typeof defaultValue == "undefined" ? "" : defaultValue
        return value ? value : defaultValue
    }
}
