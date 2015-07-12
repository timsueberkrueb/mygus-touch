import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem


Item {
    id: item_plan_students

    property string version: 'unbekannt'
    property string absent_classes: 'unbekannt'
    property string absent_courses: 'unbekannt'
    property string absent_teachers: 'unbekannt'
    property string missing_rooms: 'unbekannt'
    property string notes: 'unbekannt'


    function show_information() {
        dialog_information.show();
    }

    function set_dates(d) {
        var i = combo_dates.currentIndex;
        dates = d;
        combo_dates.currentIndex = i;
    }

    function current_date_changed(result) {
        table_view_students.model = result["model"];
        version = result['version'];
        absent_classes = result['absent_classes'];
        absent_courses = result['absent_courses'];
        absent_teachers = result['absent_teachers'];
        missing_rooms = result['missing_rooms'];
        notes = result['notes'];
    }

    Rectangle {
        id: background
        anchors.fill: parent

        Flickable {
            id: flickable

            anchors.fill: parent
            contentWidth: table_view_students.viewport.width; contentHeight: flickable.height

            Item {
                x: 0

                TableView {                    
                    id: table_view_students

                    //anchors.top: topbar.bottom

                    frameVisible: false
                    sortIndicatorVisible: true
                    alternatingRowColors: true

                    width: Units.dp(2000) //2000
                    height: flickable.height //- topbar.height

                    TableViewColumn {
                        id: columnClass
                        title: "Klasse"
                        role: "className"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnLesson
                        title: "Stunde"
                        role: "lesson"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnTeacher
                        title: "Lehrer"
                        role: "originalTeacher"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 3/14
                    }

                    TableViewColumn {
                        id: columnSubject
                        title: "Fach"
                        role: "originalSubject"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 1/14
                    }


                    TableViewColumn {
                        id: columnSubstitutionTeacher
                        title: "Vertretung"
                        role: "substitutionTeacher"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 3/14
                    }

                    TableViewColumn {
                        id: columnSubstitutionSubject
                        title: "Fach"
                        role: "substitutionSubject"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnRoom
                        title: "Raum"
                        role: "substitutionRoom"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnNotes
                        title: "Bemerkungen"
                        role: "comments"
                        movable: false
                        resizable: true
                        width: table_view_students.viewport.width * 3/14
                    }

                }

            }

        }

    }

    Dialog {
        id: dialog_information
        title: "Information"
        hasActions: false
        width: item_plan_students.width - Units.dp(30)

        GridLayout {
            columns: 2
            anchors.margins: 10
            rowSpacing: 10
            columnSpacing: 10

            Label {
                text: 'Version'
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: version
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Abwesende Klassen"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: absent_classes
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Abwesende Kurse"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: absent_courses
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Abwesende Lehrer"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: absent_teachers
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Fehlende Räume"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: missing_rooms
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Bemerkungen"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: notes
                font.pixelSize: Units.dp(16);
                //wrapMode: Text.WordWrap
            }
        }

        Button {
            text: "Okay"
            onClicked: dialog_information.close()
        }

    }
}
