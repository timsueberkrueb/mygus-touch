import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem


Item {
    id: item_plan_teachers

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
        table_view_teachers.model = result["model_teachers"];
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
            contentWidth: table_view_teachers.viewport.width; contentHeight: flickable.height

            Item {
                x: 0

                TableView {
                    id: table_view_teachers

                    //anchors.top: topbar.bottom

                    frameVisible: false
                    sortIndicatorVisible: true
                    alternatingRowColors: true

                    width: Units.dp(2000) //2000
                    height: flickable.height //- topbar.height

                    TableViewColumn {
                        title: "Lehrer"
                        role: "substitutionTeacher"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 3/14
                    }

                    TableViewColumn {
                        title: "Stunde"
                        role: "lesson"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 1/14
                    }

                    TableViewColumn {
                        title: "Klasse"
                        role: "className"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 1/14
                    }

                    TableViewColumn {
                        title: "Fach"
                        role: "substitutionSubject"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 1/14
                    }

                    TableViewColumn {
                        title: "Raum"
                        role: "substitutionRoom"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 1/14
                    }


                    TableViewColumn {
                        title: "Für"
                        role: "originalTeacher"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 3/14
                    }

                    TableViewColumn {
                        title: "Statt"
                        role: "originalSubject"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 1/14
                    }

                    TableViewColumn {
                        title: "Bemerkungen"
                        role: "comments"
                        movable: false
                        resizable: true
                        width: table_view_teachers.viewport.width * 3/14
                    }

                }

            }

        }

    }

    Dialog {
        id: dialog_information
        title: "Information"
        hasActions: false
        width: item_plan_teachers.width - Units.dp(30)

        GridLayout {
            columns: 2
            anchors.margins: 10
            rowSpacing: 10
            columnSpacing: 10

            Label {
                text: 'Version'
            }

            Label {
                text: version
            }

            Label {
                text: "Abwesende Klassen"
            }

            Label {
                text: absent_classes
            }

            Label {
                text: "Abwesende Kurse"
            }

            Label {
                text: absent_courses
            }

            Label {
                text: "Abwesende Lehrer"
            }

            Label {
                text: absent_teachers
            }

            Label {
                text: "Fehlende Räume"
            }

            Label {
                text: missing_rooms
            }

            Label {
                text: "Bemerkungen"
            }

            Label {
                text: notes
                //wrapMode: Text.WordWrap
            }
        }

        Button {
            text: "Okay"
            onClicked: dialog_information.close()
        }

    }
}
