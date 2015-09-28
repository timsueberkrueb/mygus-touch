import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1

ListItem.Subtitled {
    property string lesson: "Stunde"
    property string subject: "Fach"
    property string form: "Klasse"
    property string state: "Status"
    property string notes: "Bemerkungen"
    property var entry
    property var on_clicked

    text: lesson + '. Stunde ' + subject + ': ' + state
    subText: notes
    valueText: form

    maximumLineCount: 3
    onClicked: {
        on_clicked(this.entry)
    }
}

