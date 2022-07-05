import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../Common"

Item {
    id: nrs2002View

    property var mPatientInfo: new Object

    property var mResult: new Object
    property var mRadio: new Object

    property real bmi: main.getBMI(parseFloat(inputWeight.text), parseFloat(inputHeight.text))

    property var radio0value: radio0.checkedButton ? radio0.checkedButton.value : null
    property var radio1value: radio1.checkedButton ? radio1.checkedButton.value : null
    property var radio2value: radio2.checkedButton ? radio2.checkedButton.value : null
    property var radio3value: radio3.checkedButton ? radio3.checkedButton.value : null
    property var radio4value: radio4.checkedButton ? radio4.checkedButton.value : null
    property var radio5value: radio5.checkedButton ? radio5.checkedButton.value : null
    property var radio6value: radio6.checkedButton ? radio6.checkedButton.value : null
    property var radio7value: radio7.checkedButton ? radio7.checkedButton.value : null
    property var radio8value: radio8.checkedButton ? radio8.checkedButton.value : null
    property var radio9value: radio9.checkedButton ? radio9.checkedButton.value : null
    property var radio10value: radio10.checkedButton ? radio10.checkedButton.value : null

    property int subsum: (radio3value ? radio3value : 0) +
                         (radio9value ? radio9value : 0) +
                         (radio10value ? radio10value : 0)

    property bool weightReduced: inputOnep.value < 0 || inputTwop.value < 0 || inputThreep.value < 0
    property int maxRadioValue: Math.max(radio4value ? radio4value : 0, radio6value ? radio6value : 0, radio8value ? radio8value : 0)

    function backToList() {
        departmentStackView.pop()
    }

    function setResult() {
        mResult["PatientHospitalize_DBKey"] = mPatientInfo.id
        mResult["ScreeningDate"] = Qt.formatDateTime(outDate(), "yyyy-MM-dd hh:mm:ss")

        var nrs2002counts = new Object

        nrs2002counts["Gender"] = mPatientInfo.gender == 0 ? "M" : "F"
        if (cboDisease.currentIndex > -1) {
            nrs2002counts["Disease_DBKEY"] = gDiseaseList[cboDisease.currentIndex].id
            nrs2002counts["DiseaseName"] = gDiseaseList[cboDisease.currentIndex].name
        }
        nrs2002counts["Weight"] = inputWeight.text.trim()
        nrs2002counts["Height"] = inputHeight.text.trim()
        nrs2002counts["Age"] = mPatientInfo.age
        nrs2002counts["DepartmentName"] = mPatientInfo.department_name
        nrs2002counts["HospitalizationNumber"] = mPatientInfo.hospitalization_number
        if (mPatientInfo.in_hospital_date) {
            nrs2002counts["InHospitalData"] = Qt.formatDateTime(new Date(mPatientInfo.in_hospital_date), "yyyy-MM-dd hh:mm:ss")
        }
        nrs2002counts["PatientNo"] = mPatientInfo.number
        nrs2002counts["BedCode"] = mPatientInfo.bed_code
        nrs2002counts["PatientName"] = mPatientInfo.name
        nrs2002counts["BMI"] = bmi

        nrs2002counts["onew"] = inputOnew.text.trim()
        nrs2002counts["onep"] = inputOnep.value
        nrs2002counts["twow"] = inputTwow.text.trim()
        nrs2002counts["twop"] = inputTwop.value
        nrs2002counts["threew"] = inputThreew.text.trim()
        nrs2002counts["threep"] = inputThreep.value

        mResult["nrs2002counts"] = nrs2002counts

        var radio = new Object
        radio["0"] = radio0value ? radio0value : 0
        radio["1"] = radio1value ? radio1value : 0
        radio["2"] = radio2value ? radio2value : 0
        radio["3"] = radio3value ? radio3value : 0
        radio["4"] = radio4value ? radio4value : 0
        radio["5"] = radio5value ? radio5value : 0
        radio["6"] = radio6value ? radio6value : 0
        radio["7"] = radio7value ? radio7value : 0
        radio["8"] = radio8value ? radio8value : 0
        radio["9"] = radio9value ? radio9value : 0
        radio["10"] = radio10value ? radio10value : 0

        mResult["radio"] = radio

        return true
    }

    function save() {
        if (!setResult()) {
            return false
        }

        var resultString = JSON.stringify(mResult)

        return DBManager.setNRS2002(mPatientInfo.id, resultString, gCurrentUser.user_id)
    }

    function submit() {
        if (save()) {
            var params = {
                "user_id": gCurrentUser.id,
                "data": JSON.stringify([mResult])
            }

            main.showWaiting(true)
            ServiceManager.request("submitnrs2002", params)
        }
    }

    Connections {
        target: swipePageLoader.isCurrent ? ServiceManager : null

        onResponse: {
            if (p_serviceName == "submitnrs2002") {
                main.showWaiting(false);

                if (p_result.success) {
                    DBManager.setSubmittedNRS2002(mPatientInfo.id, true)

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

    Component.onCompleted: {
        var _mRadio = {
            "0": 1,
            "1": 1,
            "2": 0
        }

        mRadio = _mRadio

        var result = DBManager.getNRS2002(mPatientInfo.id)
        if (result) {
            mResult = JSON.parse(result)
            if (mResult) {
                mRadio = mResult["radio"]
            }
        }
    }

    Text {
        id: lblTitle
        anchors {
            left: parent.left; leftMargin: 30 * ui_RATIO
            top: parent.top; topMargin: 30 * ui_RATIO
        }
        font { pixelSize: 30 * ui_RATIO; bold: true }
        color: "#5356a5"
        text: qsTr("NRS-2002风险筛查")
    }

    Row {
        spacing: 30 * ui_RATIO
        anchors {
            left: lblTitle.right; leftMargin: 50 * ui_RATIO
            verticalCenter: lblTitle.verticalCenter
        }

        Text {
            id: txtName
            anchors.verticalCenter: parent.verticalCenter
            font { pixelSize: 28 * ui_RATIO; bold: true }
            text: mPatientInfo.name
        }

        Row {
            spacing: 10 * ui_RATIO

            Text {
                id: lblGender
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: 22 * ui_RATIO }
                color: "#657180"
                text: qsTr("性别")
            }

            Text {
                id: txtGender
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: mainFontSize }
                color: "#5356a5"
                text: mPatientInfo.gender == 0 ? qsTr("男") : qsTr("女")
            }
        }

        Row {
            spacing: 10 * ui_RATIO

            Text {
                id: lblAge
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: 22 * ui_RATIO }
                color: "#657180"
                text: qsTr("年龄")
            }

            Text {
                id: txtAge
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: mainFontSize }
                color: "#5356a5"
                text: mPatientInfo.age
            }
        }

        Row {
            spacing: 10 * ui_RATIO

            Text {
                id: lblHeight
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: 22 * ui_RATIO }
                color: "#657180"
                text: qsTr("身高")
            }

            Text {
                id: txtHeight
                anchors.verticalCenter: parent.verticalCenter
                font { pixelSize: mainFontSize }
                color: "#5356a5"
                text: mPatientInfo.height + "cm"
            }
        }
    }

    Button {
        id: buttonSubmit
        text: qsTr("提交")
        font { pixelSize: mainFontSize; bold: true }
        anchors {
            right: buttonBack.left; rightMargin: 50 * ui_RATIO
            verticalCenter: lblTitle.verticalCenter
        }
        width: 150 * ui_RATIO; height: 50 * ui_RATIO
        background: Rectangle {
            radius: 4 * ui_RATIO
            border { width: 1; color: "#7551AF" }
            color: buttonSubmit.pressed ? "white" : "#7551AF"
            opacity: buttonSubmit.enabled ? 1 : 0.3
        }
        contentItem: Text {
            text: buttonSubmit.text
            font: buttonSubmit.font
            color: buttonSubmit.pressed ? "#7551AF" : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        enabled: radio0value != null &&
                 radio1value != null &&
                 radio2value != null &&
                 radio3value != null &&
                 radio4value != null &&
                 radio5value != null &&
                 (radio6value != null || radio5value == 0) &&
                 radio7value != null &&
                 (radio8value != null || radio7value == 0) &&
                 radio9value != null &&
                 radio10value != null &&
                 !!inputHeight.text &&
                 !!inputWeight.text

        onClicked: {
            submit()
        }
    }

    Button {
        id: buttonBack
        anchors {
            right: parent.right; rightMargin: 30 * ui_RATIO
            verticalCenter: lblTitle.verticalCenter
        }
        width: 60 * ui_RATIO; height: 60 * ui_RATIO
        background: Rectangle {
            radius: height / 2
            scale: buttonBack.pressed ? 1.1 : 1.0
            color: "#5356a5"
        }
        contentItem: Image {
            source: "qrc:/images/back.png"
        }

        onClicked: {
            backToList()
        }
    }

    Rectangle {
        anchors {
            left: lblTitle.left; right: parent.right; rightMargin: 30 * ui_RATIO
            top: lblTitle.bottom; topMargin: 30 * ui_RATIO; bottom: parent.bottom; bottomMargin: 30 * ui_RATIO
        }
        border { width: 1; color: "#ccc" }

        ScrollView {
            id: scrollView
            anchors {
                left: parent.left; right: parent.right; leftMargin: 30 * ui_RATIO
                top: parent.top; topMargin: 30 * ui_RATIO; bottom: parent.bottom; bottomMargin: 30 * ui_RATIO
            }
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

            Column {
                width: scrollView.width
                spacing: 20 * ui_RATIO

                Text {
                    font { pixelSize: mainFontSize; bold: true }
                    color: "#657180"
                    text: qsTr("1.患者基本信息")
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("患者知情同意参加：")
                    }

                    Row {
                        id: rowRadio0
                        spacing: 10 * ui_RATIO
                        anchors.verticalCenter: parent.verticalCenter

                        ButtonGroup {
                            id: radio0
                            buttons: rowRadio0.children
                        }

                        Repeater {
                            id: rptRadio0
                            model: [
                                { "label": qsTr("是"), "value": 1},
                                { "label": qsTr("否"), "value": 0}
                            ]

                            JRadioButton {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                value: modelData.value

                                checked: mRadio["0"] == value
                            }
                        }
                    }
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("适用对象：18岁~90岁，住院1d以上，次日8时前未行手术，神志清者。")
                    }

                    Row {
                        id: rowRadio1
                        spacing: 10 * ui_RATIO
                        anchors.verticalCenter: parent.verticalCenter

                        ButtonGroup {
                            id: radio1
                            buttons: rowRadio1.children
                        }

                        Repeater {
                            id: rptRadio1
                            model: [
                                { "label": qsTr("是"), "value": 1},
                                { "label": qsTr("否"), "value": 0}
                            ]

                            JRadioButton {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                value: modelData.value

                                checked: mRadio["1"] == value
                            }
                        }
                    }
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("不适用对象：18岁以下，90岁以上，住院不过夜，次日8时前行手术，神志不清。")
                    }

                    Row {
                        id: rowRadio2
                        spacing: 10 * ui_RATIO
                        anchors.verticalCenter: parent.verticalCenter

                        ButtonGroup {
                            id: radio2
                            buttons: rowRadio2.children
                        }

                        Repeater {
                            id: rptRadio2
                            model: [
                                { "label": qsTr("是"), "value": 1},
                                { "label": qsTr("否"), "value": 0}
                            ]

                            JRadioButton {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                value: modelData.value

                                checked: mRadio["2"] == value
                            }
                        }
                    }
                }

                Text {
                    font { pixelSize: mainFontSize; bold: true }
                    color: "#657180"
                    text: qsTr("2.临床营养风险")
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("主要诊断：")
                    }

                    ComboBox {
                        id: cboDisease
                        width: 500 * ui_RATIO
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        textRole: "name"
                        model: gDiseaseList
                        currentIndex: mResult.nrs2002counts && mResult.nrs2002counts.DiseaseName ? find(mResult.nrs2002counts.DiseaseName) :
                                      mPatientInfo.disease_name ? find(mPatientInfo.disease_name) : -1

                        contentItem: Text {
                            leftPadding: 0
                            rightPadding: cboDisease.indicator.width + cboDisease.spacing

                            text: cboDisease.displayText
                            font: cboDisease.font
                            color: cboDisease.visualFocus ? "#7551af" : "#657180"
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 120
                            implicitHeight: 40
                            border.color: cboDisease.visualFocus ? "#7551af" : "#657180"
                            border.width: cboDisease.visualFocus ? 2 : 1
                            radius: 2
                        }
                    }
                }

                Text {
                    font { pixelSize: mainFontSize; bold: true }
                    color: "#657180"
                    text: qsTr("3.人体测量")
                }

                Row {
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("身高（经过校正的标尺，校正至0.1cm）：")
                    }

                    TextField {
                        id: inputHeight
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: mResult.nrs2002counts ? mResult.nrs2002counts.Height : mPatientInfo.height

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr(" cm（免鞋）")
                    }
                }

                Row {
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("体重（经过校正的体重计，校正至0.1kg）：")
                    }

                    TextField {
                        id: inputWeight
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: mResult.nrs2002counts ? mResult.nrs2002counts.Weight : mPatientInfo.weight

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr(" kg（空腹、病房衣服、免鞋）")
                    }
                }

                Text {
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                    font { pixelSize: mainFontSize }
                    color: "#657180"
                    text: qsTr("体质指数（体重指数，BMI）： %1  kg/m²（若BMI<18.5且一般状况差，3分，若BMI>=18.5,0分）").arg(bmi)
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        font { pixelSize: mainFontSize }
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#657180"
                        text: qsTr("一个月前体重(kg)：")
                    }

                    TextField {
                        id: inputOnew
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: mResult.nrs2002counts ? mResult.nrs2002counts.onew : ""

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }

                    TextField {
                        id: inputOnep
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        readOnly: true
                        text: value + "%"

                        property real value: main.getWeightChange(inputOnew.text, inputWeight.text)

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("二个月前体重(kg)：")
                    }

                    TextField {
                        id: inputTwow
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: mResult.nrs2002counts ? mResult.nrs2002counts.twow : ""

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }

                    TextField {
                        id: inputTwop
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: value + "%"

                        property real value: main.getWeightChange(inputTwow.text, inputWeight.text)

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }
                }

                Row {
                    spacing: 10 * ui_RATIO
                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        text: qsTr("三个月前体重(kg)：")
                    }

                    TextField {
                        id: inputThreew
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: mResult.nrs2002counts ? mResult.nrs2002counts.threew : ""

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }

                    TextField {
                        id: inputThreep
                        anchors.verticalCenter: parent.verticalCenter
                        width: 150 * ui_RATIO; height: 60 * ui_RATIO
                        font { pixelSize: mainFontSize }
                        color: "#657180"
                        validator: DoubleValidator { bottom: 0 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        text: value + "%"

                        property real value: main.getWeightChange(inputThreew.text, inputWeight.text)

                        background: Rectangle {
                            radius: 4 * ui_RATIO
                            border { width: 1; color: "#ccc" }
                        }
                    }
                }

                Item {
                    width: 10; height: 30 * ui_RATIO
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; leftMargin: 20 * ui_RATIO; rightMargin: 40 * ui_RATIO }
                    height: colNRS2002Contents.height
                    border { width: 1; color: "#ccc" }

                    Column {
                        id: colNRS2002Contents
                        anchors {
                            left: parent.left; right: parent.right; leftMargin: 20 * ui_RATIO; rightMargin: 20 * ui_RATIO
                            verticalCenter: parent.verticalCenter
                        }

                        Item {
                            anchors { left: parent.left; right: parent.right }
                            height: colNRS2002_1.height + 60 * ui_RATIO

                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: 1; color: "#ccc"
                            }

                            Column {
                                id: colNRS2002_1
                                spacing: 20 * ui_RATIO
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }

                                Text {
                                    font { pixelSize: mainFontSize; bold: true }
                                    color: "#657180"
                                    text: qsTr("NRS-2002-1 疾病评分")
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("注：未列入下述疾病者需“挂靠”，如“急性胆囊炎”、“老年痴呆”、等可挂靠于“慢性疾病急性发作或有并发症”，计1分（复核者有权决定挂靠的位置）\n髋骨折、慢性疾病急性发作或有并发症、慢性阻塞性肺病、血液透析、肝硬化、一般恶性肿瘤（1分）\n腹部大手术、脑卒中、重度肺炎、血液恶性肿瘤（2分）\n颅脑损伤、骨髓移植、APACHE-II评分ICU患者（3分）。")
                                }

                                Item {
                                    width: 10; height: 20 * ui_RATIO
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 10 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("疾病评分 ")
                                    }

                                    Row {
                                        id: rowRadio3
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio3
                                            buttons: rowRadio3.children
                                        }

                                        Repeater {
                                            id: rptRadio3
                                            model: [
                                                { "label": qsTr("0分"), "value": 0 },
                                                { "label": qsTr("1分"), "value": 1 },
                                                { "label": qsTr("2分"), "value": 2 },
                                                { "label": qsTr("3分"), "value": 3 }
                                            ]

                                            JRadioButton {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value

                                                checked: mRadio["3"] == value
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            anchors { left: parent.left; right: parent.right }
                            height: colNRS2002_2_4.height + 60 * ui_RATIO

                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: 1; color: "#ccc"
                            }

                            Column {
                                id: colNRS2002_2_4
                                spacing: 20 * ui_RATIO
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }

                                Text {
                                    font { pixelSize: mainFontSize; bold: true }
                                    color: "#657180"
                                    text: qsTr("NRS-2002-2 人体测量")
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("BMI：%1 kg/m²（若BMI<18.5且一般状况差，3分，若BMI>=18.5,0分）").arg(bmi)
                                }

                                Row {
                                    id: rowRadio4
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    ButtonGroup {
                                        id: radio4
                                        buttons: rowRadio4.children
                                    }

                                    Connections {
                                        target: nrs2002View

                                        onBmiChanged: {
                                            rptRadio4.itemAt(bmi < 18.5 ? 0 : 1).checked = true
                                        }
                                    }

                                    Repeater {
                                        id: rptRadio4
                                        model: [
                                            { "label": qsTr("BMI<18.5(3分)"), "value": 3},
                                            { "label": qsTr("BMI>=18.5(0分)"), "value": 0}
                                        ]

                                        JRadioButton {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.label
                                            value: modelData.value

                                            checked: mRadio["4"] == value
                                        }
                                    }
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("小计：%1 分").arg(radio4value ? radio4value : 0)
                                }

                                Text {
                                    font { pixelSize: mainFontSize; bold: true }
                                    color: "#657180"
                                    text: qsTr("NRS-2002-3 体重状况")
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("近期（1个月~3个月）体重是否下降？（")
                                    }

                                    Row {
                                        id: rowRadio5
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio5
                                            buttons: rowRadio5.children
                                        }

                                        Connections {
                                            target: nrs2002View

                                            onWeightReducedChanged: {
                                                rptRadio5.itemAt(nrs2002View.weightReduced ? 0 : 1).checked = true
                                            }
                                        }


                                        Repeater {
                                            id: rptRadio5
                                            model: [
                                                { "label": qsTr("是"), "value": 1 },
                                                { "label": qsTr("否"), "value": 0 }
                                            ]

                                            JRadioButton {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value

                                                checked: mRadio["5"] == value
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("）；若是体重下降 %1kg ").arg(inputOnep.value < -5 ? parseFloat(inputOnew.text.trim()) - parseFloat(inputWeight.text.trim()) :
                                                                              inputTwop.value < -5 ? parseFloat(inputTwow.text.trim()) - parseFloat(inputWeight.text.trim()) :
                                                                              inputThreep.value < -5 ? parseFloat(inputThreew.text.trim()) - parseFloat(inputWeight.text.trim()) : 0)
                                    }
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("体重下降>5%是在：")
                                    }

                                    Row {
                                        id: rowRadio6
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio6
                                            buttons: rowRadio6.children
                                        }

                                        property var checkRadio: function() {
                                            rptRadio6.itemAt(0).checked = true

                                            if (nrs2002View.weightReduced) {
                                                if (inputOnep.value < -5) {
                                                    rptRadio6.itemAt(1).checked = true
                                                }
                                                else if (inputTwop.value < -5) {
                                                    rptRadio6.itemAt(2).checked = true
                                                }
                                                else if (inputThreep.value < -5) {
                                                    rptRadio6.itemAt(3).checked = true
                                                }
                                            }
                                        }

                                        Connections {
                                            target: nrs2002View

                                            onWeightReducedChanged: {
                                                rowRadio6.checkRadio()
                                            }

                                            onRadio5valueChanged: {
                                                if (radio5value == 1) {
                                                    rowRadio6.checkRadio()
                                                }
                                            }
                                        }

                                        Repeater {
                                            id: rptRadio6
                                            model: [
                                                { "label": qsTr("其他（0分）"), "value": 0 },
                                                { "label": qsTr("3个月内（1分）"), "value": 1 },
                                                { "label": qsTr("2个月内（2分）"), "value": 2 },
                                                { "label": qsTr("1个月内（3分）"), "value": 3 }
                                            ]

                                            JRadioButton {
                                                id: radio6Button
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value
                                                enabled: radio5value == 1

                                                checked: mRadio["6"] == value

                                                Connections {
                                                    target: nrs2002View

                                                    onRadio5valueChanged: {
                                                        if (radio5value != 1) {
                                                            radio6Button.checked = value == 0
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("小计：%1 分").arg(radio6value ? radio6value : 0)
                                }

                                Text {
                                    font { pixelSize: mainFontSize; bold: true }
                                    color: "#657180"
                                    text: qsTr("NRS-2002-4 进食状况")
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("一周内进食量是否减少？（")
                                    }

                                    Row {
                                        id: rowRadio7
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio7
                                            buttons: rowRadio7.children
                                        }

                                        Repeater {
                                            id: rptRadio7
                                            model: [
                                                { "label": qsTr("是"), "value": 1 },
                                                { "label": qsTr("否"), "value": 0 }
                                            ]

                                            JRadioButton {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value

                                                checked: mRadio["7"] == value
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("）")
                                    }
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("如果减少，较从前减少：")
                                    }

                                    Row {
                                        id: rowRadio8
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio8
                                            buttons: rowRadio8.children
                                        }

                                        Repeater {
                                            id: rptRadio8
                                            model: [
                                                { "label": qsTr("其他（0分）"), "value": 0 },
                                                { "label": qsTr("25%~50%（1分）"), "value": 1 },
                                                { "label": qsTr("50%~75%（2分）"), "value": 2 },
                                                { "label": qsTr("75%~100%（3分）"), "value": 3 }
                                            ]

                                            JRadioButton {
                                                id: radio8Button
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value
                                                enabled: radio7value == 1

                                                checked: mRadio["8"] == value

                                                Connections {
                                                    target: nrs2002View

                                                    onRadio7valueChanged: {
                                                        if (radio7value != 1) {
                                                            radio8Button.checked = value == 0
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("小计：%1 分").arg(radio8value ? radio8value : 0)
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 10 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("营养受损评分 ")
                                    }

                                    Row {
                                        id: rowRadio9
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio9
                                            buttons: rowRadio9.children
                                        }

                                        Connections {
                                            target: nrs2002View

                                            onMaxRadioValueChanged: {
                                                rptRadio9.itemAt(nrs2002View.maxRadioValue).checked = true
                                            }
                                        }

                                        Repeater {
                                            id: rptRadio9
                                            model: [
                                                { "label": qsTr("0分"), "value": 0 },
                                                { "label": qsTr("1分"), "value": 1 },
                                                { "label": qsTr("2分"), "value": 2 },
                                                { "label": qsTr("3分"), "value": 3 }
                                            ]

                                            JRadioButton {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value

                                                checked: mRadio["9"] == value
                                            }
                                        }
                                    }
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("注：取上述3个小结评分中最高值。")
                                }
                            }
                        }

                        Item {
                            anchors { left: parent.left; right: parent.right }
                            height: colNRS2002_5.height + 60 * ui_RATIO

                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: 1; color: "#ccc"
                            }

                            Column {
                                id: colNRS2002_5
                                spacing: 20 * ui_RATIO
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }

                                Text {
                                    font { pixelSize: mainFontSize; bold: true }
                                    color: "#657180"
                                    text: qsTr("NRS-2002-5 年龄评分")
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("若年龄>=70岁为1分，否则为0分")
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("年龄评分 ")
                                    }

                                    Row {
                                        id: rowRadio10
                                        spacing: 10 * ui_RATIO
                                        anchors.verticalCenter: parent.verticalCenter

                                        ButtonGroup {
                                            id: radio10
                                            buttons: rowRadio10.children
                                        }

                                        Repeater {
                                            id: rptRadio10
                                            model: [
                                                { "label": qsTr("0分"), "value": 0 },
                                                { "label": qsTr("1分"), "value": 1 }
                                            ]

                                            JRadioButton {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                value: modelData.value

                                                checked: mRadio["10"] == value
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            anchors { left: parent.left; right: parent.right }
                            height: colNRS2002_total.height + 60 * ui_RATIO

                            Column {
                                id: colNRS2002_total
                                spacing: 20 * ui_RATIO
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }

                                Text {
                                    font { pixelSize: mainFontSize; bold: true }
                                    color: "#657180"
                                    text: qsTr("营养风险总评分")
                                }

                                Text {
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }
                                    font { pixelSize: mainFontSize }
                                    color: "#657180"
                                    text: qsTr("临床营养筛查总分= %1 分").arg(subsum)
                                }

                                Row {
                                    spacing: 10 * ui_RATIO
                                    anchors { left: parent.left; leftMargin: 30 * ui_RATIO }

                                    Text {
                                        font { pixelSize: mainFontSize }
                                        color: "#657180"
                                        text: qsTr("注：临床营养筛查总分 = 疾病评分 + 营养状态受损评分 + 年龄评分")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


}
