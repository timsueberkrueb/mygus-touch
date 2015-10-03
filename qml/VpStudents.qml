import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import Material 0.1
import Material.ListItems 0.1 as ListItem


Item {
    id: itemPlanStudents

    property string version: 'unbekannt'
    property string absentClasses: 'unbekannt'
    property string absentCourses: 'unbekannt'
    property string absentTeachers: 'unbekannt'
    property string missingRooms: 'unbekannt'
    property string notes: 'unbekannt'

    property alias dialogInformation: dialogInformation


    function showInformation() {
        dialogInformation.show();
    }

    function setDates(d) {
        var i = combo_dates.currentIndex;
        dates = d;
        combo_dates.currentIndex = i;
    }

    function updateCurrentDate(result) {
        tableViewStudents.model = result["model"];
        version = result['version'];
        absentClasses = result['absent_classes'];
        absentCourses = result['absent_courses'];
        absentTeachers = result['absent_teachers'];
        missingRooms = result['missing_rooms'];
        notes = result['student_notes'];
    }

    Rectangle {
        id: background
        anchors.fill: parent

        Flickable {
            id: flickable

            anchors.fill: parent
            contentWidth: tableViewStudents.viewport.width; contentHeight: flickable.height

            Item {
                x: 0

                TableView {                    
                    id: tableViewStudents

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
                        width: tableViewStudents.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnLesson
                        title: "Stunde"
                        role: "lesson"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnTeacher
                        title: "Lehrer"
                        role: "originalTeacher"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 3/14
                    }

                    TableViewColumn {
                        id: columnSubject
                        title: "Fach"
                        role: "originalSubject"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 1/14
                    }


                    TableViewColumn {
                        id: columnSubstitutionTeacher
                        title: "Vertretung"
                        role: "substitutionTeacher"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 3/14
                    }

                    TableViewColumn {
                        id: columnSubstitutionSubject
                        title: "Fach"
                        role: "substitutionSubject"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnRoom
                        title: "Raum"
                        role: "substitutionRoom"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 1/14
                    }

                    TableViewColumn {
                        id: columnNotes
                        title: "Bemerkungen"
                        role: "comments"
                        movable: false
                        resizable: true
                        width: tableViewStudents.viewport.width * 3/14
                    }

                }

            }

        }

    }

    Dialog {
        id: dialogInformation
        title: "Information"
        hasActions: false
        width: itemPlanStudents.width - Units.dp(30)

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
                text: absentClasses
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Abwesende Kurse"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: absentCourses
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Abwesende Lehrer"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: absentTeachers
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: "Fehlende Räume"
                font.pixelSize: Units.dp(16);
            }

            Label {
                text: missingRooms
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
            onClicked: dialogInformation.close()
        }

    }
}
