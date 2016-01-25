import QtQuick 2.4
import QtQuick.Layouts 1.1
import Material 0.2
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1


Item {
    implicitHeight: 0;
    id: itemOverview

    property alias dialogDetails: dialogDetails

    function updateCurrentDate(result) {
        var entries = result['relevant_entries'];
        listView.model = entries;
    }

    function showDetails(result) {
        labelClass.text = result["className"];
        labelLesson.text = result["lesson"];
        labelTeacher.text = result["originalTeacher"];
        labelSubject.text = result["originalSubject"];
        labelSubstitutionTeacher.text = result["substitutionTeacher"];
        labelSubstitutionSubject.text = result["substitutionSubject"];
        labelRoom.text = result["substitutionRoom"];
        labelNotes.text = result["comments"];
        dialogDetails.show();
    }


    View {
        id: view
        anchors {
            fill: parent
            margins: Units.dp(32)
        }

        ListItem.Standard {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            id: listItemHeader
            text: "Änderungen für Sie"
        }

        ListView {
            id: listView

            clip: true

            model: []

            anchors.top: listItemHeader.bottom
            anchors.topMargin: Units.dp(16)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            delegate: Component {
                OverviewListItem {
                    z: 0
                    property var modelData: listView.model[index]
                    entry: modelData
                    form: modelData.className
                    lesson: modelData.lesson
                    subject: modelData.originalSubject
                    state: modelData["substitutionSubject"] !== '-' ? modelData["substitutionSubject"] : modelData["substitutionTeacher"]
                    notes: modelData.comments
                    on_clicked: showDetails
                }
            }

            NoChangesOverviewListItem {
                visible: listView.model.length === 0
                subText: "Keine Änderungen für Sie heute"
            }

        }

    }

    Dialog {
        id: dialogDetails
        title: "Details"
        hasActions: false
        width: itemOverview.width - Units.dp(30)

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
                id: labelClass
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Stunde"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: labelLesson
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Lehrer"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: labelTeacher
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Fach"
                font.pixelSize: Units.dp(16);
            }


            Label {
                id: labelSubject
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Lehrer"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: labelSubstitutionTeacher
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Fach"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: labelSubstitutionSubject
                font.pixelSize: Units.dp(16);
            }


            Label {
                text: "Raum"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: labelRoom
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Bemerkungen"
                font.pixelSize: Units.dp(16);
            }

            Label {
                id: labelNotes
                font.pixelSize: Units.dp(16);
            }

        }

        Button {
            text: "Okay"
            onClicked: dialogDetails.close()
        }

    }

}
