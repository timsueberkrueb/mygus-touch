import QtQuick 2.4
import Material 0.2


View {
    elevation: Units.dp(2)
    height: indicator.height + Units.dp(16)
    width: indicator.width + Units.dp(16)
    radius: width/2

    ProgressCircle {
        id: indicator

        anchors.centerIn: parent

        SequentialAnimation {
            running: true
            loops: Animation.Infinite

            ColorAnimation {
                from: "red"
                to: "blue"
                target: indicator
                properties: "color"
                easing.type: Easing.InOutQuad
                duration: 2400
            }

            ColorAnimation {
                from: "blue"
                to: "green"
                target: indicator
                properties: "color"
                easing.type: Easing.InOutQuad
                duration: 1560
            }

            ColorAnimation {
                from: "green"
                to: "#FFCC00"
                target: indicator
                properties: "color"
                easing.type: Easing.InOutQuad
                duration:  840
            }

            ColorAnimation {
                from: "#FFCC00"
                to: "red"
                target: indicator
                properties: "color"
                easing.type: Easing.InOutQuad
                duration:  1200
            }
        }
    }

}
