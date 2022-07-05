import QtQuick 2.7
import QtQuick.Controls 2.0

RadioButton {
      id: control
      font { pixelSize: 25 * ui_RATIO }

      property color textColor: "#657180"

      property int value: 0

      indicator: Rectangle {
          width: 32 * ui_RATIO
          height: 32 * ui_RATIO
          x: control.leftPadding
          y: parent.height / 2 - height / 2
          radius: height / 2
          border.color: control.checked && control.enabled ? "#7551af" : "#657180"

          Rectangle {
              anchors {
                  fill: parent; margins: 5 * ui_RATIO
              }
              radius: height / 2
              color: control.checked && control.enabled ? "#7551af" : "#657180"
              visible: control.checked
          }
      }

      contentItem: Text {
          text: control.text
          font: control.font
          color: textColor
          verticalAlignment: Text.AlignVCenter
          leftPadding: control.indicator.width + control.spacing
      }
  }
