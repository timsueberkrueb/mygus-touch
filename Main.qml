import QtQuick 2.2
import QtQuick.Controls 1.2 as Controls
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0
import Material 0.1


ApplicationWindow {
    id: main_window
    visible: true

    width: if (Device.type in [Device.phone, Device.phablet, Device.tablet]) {Screen.desktopAvailableWidth} else {Units.dp(800)}
    height: if (Device.type in [Device.phone, Device.phablet, Device.tablet]) {Screen.desktopAvailableHeight} else {Units.dp(600)}

    property int login_mode: 0
    property string login_state: "loading"
    property var login_text: {"loading": "Sie werden angemeldet, bitte warten ...",
                              "logged_out": "Sie sind abgemeldet",
                              "logged_in": "Sie sind angemeldet"};
    property var login_color: {"loading": "#DF7401",
                               "logged_out": "#FF3300",
                               "logged_in": "#009933"};

    property var table_model_studends: []
    property var table_model_teachers: []

    property var last_primary_color
    property var last_accent_color
    property var last_background_color

    property var dates: []
    property int current_date: 0
    property string current_weekday: ""

    property var welcome_messages
    property int current_welcome_message: 0

    property var py: false

    theme {
        primaryColor: "#FF4719"
        accentColor: "#FF9E00"
    }


    function load() {
        py.call("main.load", [], function callback(result){
            input_username.text = result["username"];
            input_password.text = result["password"];
            login_mode = result["login_mode"];
            login(result["dates"]);
        })
    }

    function load_theme (){
        py.call("main.load_theme", [], function callback(result){
            if (!result["error"]){
                theme.primaryColor = result['primary_color'];
                theme.accentColor = result['accent_color'];
                theme.backgroundColor = result['background_color'];
            }

            last_primary_color = "" + theme.primaryColor;
            last_accent_color = "" + theme.accentColor;
            last_background_color = "" + theme.backgroundColor;
        })
    }

    function login(dates) {
            snackbar.open("Sie werden angemeldet, bitte warten ...");
            main_page.title = 'Lädt ...';
            loading_indicator.visible = true;

            login_state = 'loading';
            py.call("main.login", [input_username.text, input_password.text, login_mode], function callback(result) {
                if (result) {
                    if (login_mode === 0) {
                        vp_loader.source = Qt.resolvedUrl('vp_students.qml');
                    }
                    else {
                        vp_loader.source = Qt.resolvedUrl('vp_teachers.qml');
                    }
                    set_dates(dates);
                    set_current_date(0);
                }
                main_page.title = 'MyGUS';

                if (result === "NETWORK_ERROR") {
                    login_state = 'logged_out';
                    loading_indicator.visible = false;
                    snackbar.open('Netzwerkfehler: Überprüfen Sie Ihre Verbindung');
                }
                else if (result) {
                    snackbar.open('Willkommen!');
                    login_state = 'logged_in';
                    refresh();
                }
                else {
                    login_state = 'logged_out';
                    snackbar.open('Falsche Anmeldedaten, Sie sind abgemeldet!');
                    loading_indicator.visible = false;
                    dialog_login.show();
                }
            })
    }

    function refresh() {
        if (login_state === 'logged_in') {
            snackbar.open('Vertretungspläne werden aktualisiert ...');
            main_page.title = 'Aktualisiere ...';
            py.call("main.refresh", [], function callback(result) {
                loading_indicator.visible = false;
                main_page.title = 'MyGUS';
                if (!result["error"]){
                    var current_date_before = current_date;
                    set_dates(result["dates"]);
                    if (dates.length + 1 >= current_date_before) {
                        set_current_date(current_date);
                    }
                    else {
                        set_current_date(0);
                    }

                    snackbar.open('Vertretungspläne aktualisiert');
                    show_welcome_messages();
                }
                else {
                    snackbar.open('Netzwerkfehler: Überprüfen Sie Ihre Verbindung');
                }
            })
        }
        else {
            snackbar.open('Melden Sie sich an!');
        }
    }

    function show_information() {
        //if (login_state === 'logged_in')
        vp_loader.item.show_information();
        //else
        //    show_about();
    }

    function show_about() {
        dialog_about.show();
    }

    function show_options() {
        dialog_options.show();
    }

    function set_dates(d) {
        dates = d;
        //vp_loader.item.set_dates(d);
        //console.log(d, d[current_date], d.length);
    }

    function set_current_date(d) {
        current_date = d;
        current_date_changed();
    }

    function current_date_changed(d){
        if(current_date + 1 < dates.length){
            action_date_next.enabled = true;
        }
        else {
            action_date_next.enabled = false;
        }

        if (current_date > 0) {
            action_date_before.enabled = true;
        }
        else {
            action_date_before.enabled = false;
        }
        py.call("main.date_changed", [dates[current_date]], function callback(result) {
                vp_loader.item.current_date_changed(result);
                overview_loader.item.current_date_changed(result);
                main_page.title = result["weekday"] + ', ' + dates[current_date].slice(0, -5);
        })
    }

    function date_next() {
        current_date += 1;
        current_date_changed();
    }

    function date_before() {
        current_date -= 1;
        current_date_changed();
    }

    function show_welcome_messages() {
        py.call("main.get_welcome_messages", [], function callback(result) {
            if (result.length > 0){
                welcome_messages = result;
                current_welcome_message = 0;
                show_welcome_message(current_welcome_message);
            }

        })

    }

    function show_welcome_message(i) {
        if (welcome_messages.length >= i) {
            dialog_welcome_message.msg_id = welcome_messages[i]['id'];
            dialog_welcome_message.title = welcome_messages[i]['title'];
            dialog_welcome_message.text = welcome_messages[i]['text'];
            dialog_welcome_message.priority = welcome_messages[i]['priority'];
            checkbox_show_again.checked = welcome_messages[i]['priority'] !== 'high';
            dialog_welcome_message.show();
        }
    }


    /*initialPage: Page {
        title: "Essen bestellen"
        WebView {
            anchors.fill: parent
            url: "http://gus.sams-on.de"
        }

    }

    Label {
        x: 165
        y: 15
        font.pixelSize: 24
        color: 'white'
        text: main_window.height.toString() + '/' + main_window.width.toString()
    }*/

    initialPage: Page {
        id: main_page
        title: "MyGUS"

        actions: [

            Action {
                id: action_date_before
                iconName: "image/navigate_before"
                name: "Vorheriger Tag"
                onTriggered: date_before();
                enabled: if (current_date !== 0) {true} else {false}
            },

            Action {
                id: action_date_next
                iconName: "image/navigate_next"
                name: "Nächster Tag"
                onTriggered: date_next();
                //enabled: if(current_date + 1 !== dates.length){true} else {false}

            },


            Action {
                iconName: "navigation/refresh"
                name: "Aktualisieren"
                onTriggered: refresh();
            },

            Action {
               iconName: "maps/local_restaurant"
               name: "Essen bestellen"
               onTriggered: {
                   pageStack.push(Qt.resolvedUrl("mensa.qml"))
               }

            },

            Action {
               iconName: "av/web"
               name: "News"
               onTriggered: {
                   pageStack.push(Qt.resolvedUrl("news.qml"))
               }

            },

            Action {
                iconName: "action/account_circle"
                name: "Login"
                onTriggered: dialog_login.show();
            },

            Action {
                iconName: "action/settings"
                name: "Optionen"
                onTriggered: show_options();
            }
        ]

        tabs: [
            // Each tab can have text and an icon
            {
                text: "Übersicht",
                icon: "action/home"
            },

            {
                text: "Plan",
                icon: "action/subject"
            },

        ]

        TabView {
            id: tabView
            anchors.fill: parent
            currentIndex: main_page.selectedTab
            model: tabs
        }

        VisualItemModel {
            id: tabs

            // Tab "Überblick"
            Rectangle {
                width: tabView.width
                height: tabView.height
                Flickable {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    clip: true
                    contentHeight: Math.max(overview_loader.implicitHeight, height)
                    Loader {
                        id: overview_loader
                        anchors.fill: parent
                        // selectedComponent will always be valid, as it defaults to the first component
                        source: Qt.resolvedUrl("overview_students.qml")
                    }
                }
            }

            // Tab "Vertretungsplan"
            Rectangle {
                width: tabView.width
                height: tabView.height
                Flickable {
                    id: flickable
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    clip: true
                    contentHeight: Math.max(vp_loader.implicitHeight + Units.dp(45), height)
                    Loader {
                        id: vp_loader
                        anchors.fill: parent
                        // selectedComponent will always be valid, as it defaults to the first component
                        //source: Qt.resolvedUrl("vp_students.qml")
                    }
                }
            }

            /*Rectangle {
                width: tabView.width
                height: tabView.height
                Flickable {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    clip: true
                    contentHeight: Math.max(vp_loader.implicitHeight + Units.dp(45), height)
                    Loader {
                        id: mensa_loader
                        anchors.fill: parent
                        // selectedComponent will always be valid, as it defaults to the first component
                        source: Qt.resolvedUrl("mensa.qml")
                    }
                }
            }*/

        }

    }

    Dialog {
        id: dialog_login
        title: "Login"
        positiveButtonText: "Login"

        Column {
            anchors.rightMargin: 8
            anchors.bottomMargin: 16
            anchors.leftMargin: 24
            anchors.topMargin: 10
            spacing: 6
            anchors {
                margins: 10
            }

            Label {
                text: login_text[login_state]
                color: login_color[login_state]
            }

            Controls.TextField {
                id: input_username
                placeholderText: "username"
            }

            Controls.TextField {
                id: input_password
                placeholderText: "password"
                echoMode: TextInput.Password

            }

            Controls.ComboBox {
                id: combo_login_mode
                model: ['Ich bin ein Schüler', 'Ich bin ein Lehrer']
                currentIndex: login_mode
                onCurrentIndexChanged: {
                    login_mode = this.currentIndex;
                }
            }

        }

        onAccepted: {
            login(dates);
        }

        onVisibleChanged: {
            if (!dialog_login.visible){
                if (login_state === 'logged_out' && input_username.text === '' && input_password.text == ''){
                    dialog_login.show();
                    snackbar.open('Geben Sie Ihre Anmeldedaten ein!');
                }
            }
        }

    }


    Dialog {
        id: dialog_about

        title: "Über MyGUS"
        hasActions: false

        Column {
            anchors.rightMargin: 8
            anchors.bottomMargin: 16
            anchors.leftMargin: 24
            anchors.topMargin: 10
            spacing: 6
            anchors {
                margins: 10
            }

            Label {
                wrapMode: Text.WordWrap
                width: main_window.width - Units.dp(100)
                font.pixelSize: Units.dp(16);
                text: "MyGUS ist ein Schulplaner für das Gymnasium Unterrieden Sindelfingen\n© Copyright Tim Süberkrüb, 2014-2015\nDiese App benutzt Python, PyOtherSide, QML (Qt), QML-Material und QtQuick."
            }

            Button {
                text: "Okay"
                onClicked: dialog_about.close();
            }

        }
    }

    Dialog {
        id: dialog_welcome_message

        title: "Willkommen"
        property string text: "Keine Daten verfügbar :("
        property var msg_id
        property var priority: "standard"
        hasActions: false


        Column {
            anchors.rightMargin: Units.dp(8)
            anchors.bottomMargin: Units.dp(16)
            anchors.leftMargin: Units.dp(24)
            anchors.topMargin: Units.dp(10)
            spacing: Units.dp(6)
            anchors {
                margins: Units.dp(10)
            }

            Label {
                wrapMode: Text.WordWrap
                width: main_window.width - Units.dp(100)
                text: dialog_welcome_message.text
                font.pixelSize: Units.dp(16);
            }

            CheckBox {
                id: checkbox_show_again
                text: "Nicht mehr anzeigen"
                checked: dialog_welcome_message.priority !== "high"
            }

            Button {
                text: "Okay"
                onClicked: dialog_welcome_message.close();
            }

        }

        onVisibleChanged: {
            if (!dialog_welcome_message.visible && dialog_welcome_message.msg_id) {
                if (checkbox_show_again.checked) {
                    py.call('main.set_welcome_message_read', [dialog_welcome_message.msg_id]);
                }
                if(current_welcome_message +1 !== welcome_messages.length) {
                    current_welcome_message += 1;
                    show_welcome_message(current_welcome_message);
                }

            }
        }
    }

    Dialog {
        id: dialog_options
        hasActions: false

        title: "Optionen"

        Column {
            anchors.rightMargin: Units.dp(8)
            anchors.bottomMargin: Units.dp(16)
            anchors.leftMargin: Units.dp(24)
            anchors.topMargin: Units.dp(24)
            spacing: Units.dp(16)
            anchors {
                margins: Units.dp(10)
            }

            Button {
                text: "Design ändern"
                onClicked: {
                    dialog_options.close();
                    dialog_design.show();
                }
            }

            Button {
                text: "Über MyGUS"
                onClicked: {
                    dialog_options.close();
                    show_about();
                }
            }

            Button {
                text: "Abbrechen"
                onClicked: {
                    dialog_options.close();
                }
            }

        }
    }

    Dialog {
        id: dialog_design
        title: "Design"

        positiveButtonText: "Fertig"


        MenuField {
            id: selection
            model: ["Primärfarbe", "Akzentfarbe", "Hintergrundfarbe"]
            width: Units.dp(160)
        }

        Grid {
            columns: 7
            spacing: Units.dp(8)

            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]

                Rectangle {
                    width: Units.dp(30)
                    height: Units.dp(30)
                    radius: Units.dp(2)
                    color: Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? Units.dp(2) : 0
                    border.color: Theme.alpha("#000", 0.26)

                    Ink {
                        anchors.fill: parent

                        onPressed: {
                            switch(selection.selectedIndex) {
                                case 0:
                                    theme.primaryColor = parent.color
                                    break;
                                case 1:
                                    theme.accentColor = parent.color
                                    break;
                                case 2:
                                    theme.backgroundColor = parent.color
                                    break;
                            }
                        }
                    }
                }
            }
        }

        onRejected: {
            theme.primaryColor = last_primary_color;
            theme.accentColor = last_accent_color;
            theme.backgroundColor = last_background_color;
        }

        onAccepted: {
            last_primary_color = "" + theme.primaryColor;
            last_accent_color = "" + theme.accentColor;
            last_background_color = "" + theme.backgroundColor;
            py.call("main.save_theme", [last_primary_color, last_accent_color, last_background_color], function callback(result) {})
        }

    }

    ActionButton {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: Units.dp(32)
            }

            iconName: "action/info"
            onClicked: {
                show_information();
            }
    }

    Snackbar {
        id: snackbar
    }

    LoadingIndicator {
        id: loading_indicator
        anchors.centerIn: parent
    }

    Loader {
        id: python_core_loader
        onLoaded: {
            console.log("Python core loaded")
            main_window.py = item;
            load_theme();
            load();
        }

    }
    Component.onCompleted: {
        console.log("Loading python core ...")
        python_core_loader.source = Qt.resolvedUrl("python_core.qml");
    }

}
