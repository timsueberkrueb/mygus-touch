import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1

ListItem.Subtitled {
    text: 'Keine Änderungen'
    subText: 'Keine Änderungen heute für deine Klasse'
    action: Icon {
        anchors.centerIn: parent
        color: "#4CAF50"
        name: "action/check_circle"
        size: Units.dp(32)
    }
}

