import QtQuick 2.0
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1


Item {
    implicitHeight: 0;
    id: item_overview

    property Component overview_list_item: Qt.createComponent("OverviewListItem.qml");
    property Component no_changes_list_item: Qt.createComponent("NoChangesOverviewListItem.qml");


    function clear_entries() {
        for(var i = column.children.length; i > 1 ; i--) {
          column.children[i-1].destroy()
        }
    }

    function current_date_changed(result) {
        item_overview.implicitHeight = list_item_header.height + view.anchors.margins * 2;
        clear_entries();
        var entries = result['relevant_entries'];
        if (entries.length === 0) {
            var new_item = no_changes_list_item.createObject(column);
        }
        else {
            for (var i=0; i<entries.length; i++){
                var entry = entries[i];
                var new_item = overview_list_item.createObject(column);
                new_item.entry = entry
                new_item.form = entry["className"];
                new_item.lesson = entry["lesson"];
                new_item.subject = entry["originalSubject"];
                if(entry["substitutionSubject"] !== '-') {
                    new_item.state = entry["substitutionSubject"];
                }
                else {
                    new_item.state = entry["substitutionTeacher"];
                }
                new_item.notes = entry["comments"]
                new_item.on_clicked = show_details
                item_overview.implicitHeight += new_item.height;
            }

        }
    }

    function show_details(result) {
        label_class.text = result["className"];
        label_lesson.text = result["lesson"];
        label_teacher.text = result["originalTeacher"];
        label_subject.text = result["originalSubject"];
        label_substituion_teacher.text = result["substitutionTeacher"];
        label_substitution_subject.text = result["substitutionSubject"];
        label_room.text = result["substitutionRoom"];
        label_notes.text = result["comments"];
        dialog_details.show();
    }


    View {
        id: view
        anchors {
            fill: parent
            margins: Units.dp(32)
        }

        //elevation: 1

        Column {
            id: column
            anchors.fill: parent

            ListItem.Standard {
                id: list_item_header
                text: "Änderungen für meine Klasse"
            }

        }
    }

    Dialog {
        id: dialog_details
        title: "Details"
        hasActions: false
        width: item_overview.width - Units.dp(30)

        GridLayout {
            columns: 2
            anchors.margins: 10
            rowSpacing: 10
            columnSpacing: 10

            Label {
                text: 'Klasse'
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_class
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Stunde"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_lesson
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Lehrer"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_teacher
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Fach"
                font.pixelSize: Units.dp(16);
            }


            Label {
                id: label_subject
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Lehrer"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_substituion_teacher
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Fach"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_substitution_subject
                font.pixelSize: Units.dp(16);
            }


            Label {
                text: "Raum"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_room
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Bemerkungen"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: label_notes
                font.pixelSize: Units.dp(16);
            }

        }

        Button {
            text: "Okay"
            onClicked: dialog_details.close()
        }

    }

}
