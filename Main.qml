import QtQuick 2.4
import QtQuick.Controls 1.3 as Controls
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0
import Material 0.2
import Material.ListItems 0.1 as ListItem
import "qml"
import io.thp.pyotherside 1.4



ApplicationWindow {
    id: mainWindow
    visible: false

    width: Device.isMobile ? Screen.desktopAvailableWidth : Units.dp(800)
    height: Device.isMobile ? Screen.desktopAvailableHeight : Units.dp(600)

    property int loginMode: 0
    property string loginState: "loading"
    property var loginText: {"loading": "Sie werden angemeldet, bitte warten ...",
                              "logged_out": "Sie sind abgemeldet",
                              "logged_in": "Sie sind angemeldet"};
    property var loginColor: {"loading": "#DF7401",
                               "logged_out": "#FF3300",
                               "logged_in": "#009933"};

    property var tableModelStudends: []
    property var tableModelTeachers: []

    property var lastPrimaryColor
    property var lastAccentColor
    property var lastBackgroundColor

    property var dates: []
    property int currentDate: 0
    property string currentWeekday: ""

    property var welcomeMessages
    property int currentWelcomeMessage: 0

    property bool mobileMode: Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2)) < Units.dp(1000) || width < Units.dp(640)

    property bool dialogShowing: ((dialogAbout.visible || dialogDesign.visible || dialogLogin.visible || dialogOptions.visible || dialogWelcomeMessage.visible) ||
                                (vpLoader.item !== null ? vpLoader.item.dialogInformation.visible : false) ||
                                (overviewLoader.item !== null ? overviewLoader.item.dialogDetails.visible : false))

    theme {
        primaryColor: "#FF4719"
        accentColor: "#FF9E00"
    }


    function load() {
        py.call("backend.load", [], function callback(result){
            inputUsername.text = result["username"];
            inputPassword.text = result["password"];
            loginMode = result["login_mode"];
            inputFullName.text = result["full_name"];
            login(result["dates"]);
        })
    }

    function load_theme () {
        py.call("backend.load_theme", [], function callback(result){
            if (!result["error"]){
                theme.primaryColor = result['primary_color'];
                theme.accentColor = result['accent_color'];
                theme.backgroundColor = result['background_color'];
            }

            lastPrimaryColor = "" + theme.primaryColor;
            lastAccentColor = "" + theme.accentColor;
            lastBackgroundColor = "" + theme.backgroundColor;
        })
    }

    function login(dates) {
            snackbar.open("Sie werden angemeldet, bitte warten ...");
            mainPage.title = 'Lädt ...';
            loadingIndicator.visible = true;

            loginState = 'loading';
            py.call("backend.login", [inputUsername.text, inputPassword.text, loginMode, inputFullName.text], function callback(result) {
                if (result) {
                    if (loginMode === 0) {
                        overviewLoader.source = Qt.resolvedUrl('qml/OverviewStudents.qml')
                        vpLoader.source = Qt.resolvedUrl('qml/VpStudents.qml');
                    }
                    else {
                        overviewLoader.source = Qt.resolvedUrl('qml/OverviewTeachers.qml')
                        vpLoader.source = Qt.resolvedUrl('qml/VpTeachers.qml');
                    }
                    setDates(dates);
                    setCurrentDate(0);
                }
                mainPage.title = 'MyGUS';

                if (result === "NETWORK_ERROR") {
                    loginState = 'logged_out';
                    loadingIndicator.visible = false;
                    snackbar.open('Netzwerkfehler: Überprüfen Sie Ihre Verbindung');
                }
                else if (result) {
                    snackbar.open('Willkommen!');
                    loginState = 'logged_in';
                    refresh();
                }
                else {
                    loginState = 'logged_out';
                    snackbar.open('Falsche Anmeldedaten, Sie sind abgemeldet!');
                    loadingIndicator.visible = false;
                    dialogLogin.show();
                }
            })
    }

    function refresh() {
        if (loginState === 'logged_in') {
            snackbar.open('Vertretungspläne werden aktualisiert ...');
            mainPage.title = 'Aktualisiere ...';
            py.call("backend.refresh", [], function callback(result) {
                loadingIndicator.visible = false;
                mainPage.title = 'MyGUS';
                if (!result["error"]){
                    var currentbeforeDate = currentDate;
                    setDates(result["dates"]);
                    if (dates.length + 1 >= currentbeforeDate) {
                        setCurrentDate(currentDate);
                    }
                    else {
                        setCurrentDate(0);
                    }

                    snackbar.open('Vertretungspläne aktualisiert');
                    showWelcomeMessages();
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

    function showInformation() {
        if (loginState === 'logged_in')
            vpLoader.item.showInformation();
        else
            showAbout();
    }

    function showAbout() {
        dialogAbout.show();
    }

    function showOptions() {
        dialogOptions.show();
    }

    function setDates(d) {
        dates = d;
    }

    function setCurrentDate(d) {
        currentDate = d;
        updateCurrentDate();
    }

    function updateCurrentDate(d){
        if(currentDate + 1 < dates.length){
            actionDateNext.enabled = true;
        }
        else {
            actionDateNext.enabled = false;
        }

        if (currentDate > 0) {
            actionDateBefore.enabled = true;
        }
        else {
            actionDateBefore.enabled = false;
        }
        py.call("backend.date_changed", [dates[currentDate]], function callback(result) {
                vpLoader.item.updateCurrentDate(result);
                overviewLoader.item.updateCurrentDate(result);
                mainPage.title = result["weekday"] + ', ' + dates[currentDate].slice(0, -5);
        })
    }

    function nextDate() {
        currentDate += 1;
        updateCurrentDate();
    }

    function beforeDate() {
        currentDate -= 1;
        updateCurrentDate();
    }

    function showWelcomeMessages() {
        py.call("backend.get_welcome_messages", [], function callback(result) {
            if (result.length > 0){
                welcomeMessages = result;
                currentWelcomeMessage = 0;
                showWelcomeMessage(currentWelcomeMessage);
            }

        })

    }

    function showWelcomeMessage(i) {
        if (welcomeMessages.length >= i) {
            dialogWelcomeMessage.msg_id = welcomeMessages[i]['id'];
            dialogWelcomeMessage.title = welcomeMessages[i]['title'];
            dialogWelcomeMessage.text = welcomeMessages[i]['text'];
            dialogWelcomeMessage.priority = welcomeMessages[i]['priority'];
            checkboxShowAgain.checked = welcomeMessages[i]['priority'] !== 'high';
            dialogWelcomeMessage.show();
        }
    }

    // Workaround for pixel density bugs

    function fixDensity() {
        // BQ Devices
        var bqAquarisE45 =
                (Screen.width == 540) &&
                (Screen.height == 960) &&
                (Screen.pixelDensity.toFixed(2) == 3.94) &&
                (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (bqAquarisE45) {
            Units.multiplier = 2;
        }

        var bqAquarisE5 =
            (Screen.width == 720) &&
            (Screen.height == 1280) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (bqAquarisE5) {
            Units.multiplier = 3.03
        }

        // Meizu Devices
        var meizuMX4 =
            (Screen.width == 1152) &&
            (Screen.height == 1920) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (meizuMX4) {
            Units.multiplier = 4.11
        }

        // Google Nexus Devices
        var googleNexus4 =
            (Screen.width == 768) &&
            (Screen.height == 1280) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (googleNexus4) {
            Units.multiplier = 3.23
        }

        var googleNexus5 =
            (Screen.width == 1080) &&
            (Screen.height == 1920) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (googleNexus5) {
            Units.multiplier = 4.11
        }

        var googleNexus7 =
            (Screen.width == 1200) &&
            (Screen.height == 1920) &&
            (Screen.pixelDensity.toFixed(2) == 3.94) &&
            (Screen.logicalPixelDensity.toFixed(2) == 3.94)
        if (googleNexus7) {
            Units.multiplier = 3.23
        }

    }

    // Workaround for icons not showing up on Android
    Item {
        id: androidIconsWorkaround
        y: - Units.dp(256)
        Repeater {
            model: [
                "navigation/menu",
                "navigation/arrow_back",
                "navigation/refresh",
                "action/delete",
                "navigation/arrow_drop_down",
                "navigation/more_vert",
            ]
            delegate: Icon { name: modelData }
        }
    }

    initialPage: TabbedPage {
        id: mainPage
        title: "MyGUS"

        actions: [

            Action {
                id: actionDateBefore
                iconName: "image/navigate_before"
                onTriggered: beforeDate();
                enabled: if (currentDate !== 0) {true} else {false}
                tooltip: ""
            },

            Action {
                id: actionDateNext
                iconName: "image/navigate_next"
                onTriggered: nextDate();
                //enabled: if(currentDate + 1 !== dates.length){true} else {false}
                tooltip: ""
            },

            Action {
                iconName: "navigation/refresh"
                name: "Aktualisieren"
                onTriggered: refresh();
                visible: !mobileMode
            },

            Action {
               iconName: "maps/local_restaurant"
               name: "Essen bestellen"
               onTriggered: {
                   if (Qt.platform.os === "android")
                        Qt.openUrlExternally('https://gus.sams-on.de/')
                   else
                        pageStack.push(Qt.resolvedUrl("qml/Mensa.qml"))
               }
               visible: !mobileMode
            },

            Action {
               iconName: "av/web"
               name: "News"
               onTriggered: {
                   if (Qt.platform.os === "android")
                      Qt.openUrlExternally('http://www.gymnasium-unterrieden.de/')
                   else
                      pageStack.push(Qt.resolvedUrl("qml/News.qml"))
               }
               visible: !mobileMode
            },

            Action {
                iconName: "action/account_circle"
                name: "Login"
                onTriggered: dialogLogin.show();
                visible: !mobileMode
            },

            Action {
                iconName: "action/settings"
                name: "Optionen"
                onTriggered: showOptions();
                visible: !mobileMode
            }
        ]

        backAction: navDrawer.action

        NavigationDrawer {
            id: navDrawer

            enabled: mobileMode && !dialogShowing

            Component.onCompleted: action.name = ""

            Flickable {
                anchors.fill: parent

                contentHeight: Math.max(content.implicitHeight, height)

                Column {
                    id: content
                    anchors.fill: parent

                    Row {
                        height: Units.dp(96)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Units.dp(16)
                        anchors.margins: Units.dp(16)

                        Image {
                            id: name
                            anchors.verticalCenter: parent.verticalCenter
                            width: Units.dp(64)
                            height: Units.dp(64)
                            source: Qt.resolvedUrl("icon.png")
                            smooth: true
                        }

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "MyGUS"
                            font.pixelSize: Units.dp(18)
                        }

                    }


                    Repeater {
                        model: mainPage.actions
                        delegate: ListItem.Standard {

                            visible: index > 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: Units.dp(16)
                                spacing: Units.dp(16)

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: model.iconName
                                }

                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: model.name
                                    font.pixelSize: Units.dp(16)
                                }

                            }

                            onClicked: {
                                mainPage.actions[index].triggered(mainPage);
                                navDrawer.close();
                            }

                        }

                    }


                    ListItem.Standard {

                        Row {
                            anchors.fill: parent
                            anchors.margins: Units.dp(16)
                            spacing: Units.dp(16)

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "action/info"
                            }

                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Über"
                                font.pixelSize: Units.dp(16)
                            }

                        }

                        onClicked: {
                            showAbout();
                            navDrawer.close();
                        }

                    }

                }

                Label {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Units.dp(16)

                    visible: navDrawer.height > Units.dp(420)

                    text: "MyGUS - © 2016 by Tim Süberkrüb"

                }
            }
        }

        Tab {
            id: tabOverview
            title: "Übersicht"
            iconName: "action/home"
        }

        Tab {
            id: tabPlan
            title: "Plan"
            iconName: "action/subject"
        }

        Item {
            visible: mainPage.selectedTab === 0
            anchors.fill: parent

            Loader {
                id: overviewLoader
                anchors.fill: parent
            }

        }

        Item {
            visible: mainPage.selectedTab === 1
            anchors.fill: parent

            Loader {
                id: vpLoader
                anchors.fill: parent
            }

        }

    }

    Dialog {
        id: dialogLogin
        title: "Login"
        positiveButtonText: "Login"
        negativeButtonText: "Abbrechen"

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
                text: loginText[loginState]
                color: loginColor[loginState]
            }

            TextField {
                id: inputUsername
                height: Units.dp(36)
                width: parent.width
                placeholderText: comboLoginMode.selectedIndex === 0 ? "Klasse" : "Benutzername"
                onAccepted: {
                    inputFullName.forceActiveFocus();
                }
            }

            TextField {
                id: inputFullName
                width: parent.width
                height: Units.dp(36)
                placeholderText: comboLoginMode.selectedIndex === 0 ? "Dein Name (optional)" : "Name z.B. Herr Pfeiffer"
                onAccepted: {
                    inputPassword.forceActiveFocus();
                }
            }

            TextField {
                id: inputPassword
                width: parent.width
                height: Units.dp(36)
                placeholderText: "Password"
                echoMode: TextInput.Password
                onAccepted: {
                    dialogLogin.close();
                    login(dates);
                }

            }

            MenuField {
                id: comboLoginMode
                model: ['Ich bin ein Schüler', 'Ich bin ein Lehrer']
                selectedIndex: loginMode
                onSelectedIndexChanged: {
                    loginMode = this.selectedIndex;
                }
            }

        }

        onAccepted: {
            login(dates);
        }

        onVisibleChanged: {
            if (!dialogLogin.visible){
                if (loginState === 'logged_out' && inputUsername.text === '' && inputPassword.text == ''){
                    dialogLogin.show();
                    snackbar.open('Geben Sie Ihre Anmeldedaten ein!');
                }
            }
        }

    }


    Dialog {
        id: dialogAbout

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
                width: mainWindow.width - Units.dp(100)
                font.pixelSize: Units.dp(16);
                text: "MyGUS ist ein Schulplaner für das Gymnasium Unterrieden Sindelfingen.\nVielen Dank an Julian Schließus und Dominik Stiller ohne die MyGUS so nicht existieren würde :)\nDiese App benutzt Python, PyOtherSide, QML (Qt), QML-Material und QtQuick.\n© Copyright Tim Süberkrüb, 2014-2016"
            }

            Button {
                text: "Okay"
                onClicked: dialogAbout.close();
            }

        }
    }

    Dialog {
        id: dialogWelcomeMessage

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
                width: mainWindow.width - Units.dp(100)
                text: dialogWelcomeMessage.text
                font.pixelSize: Units.dp(16);
            }

            CheckBox {
                id: checkboxShowAgain
                text: "Nicht mehr anzeigen"
                checked: dialogWelcomeMessage.priority !== "high"
            }

            Button {
                text: "Okay"
                onClicked: dialogWelcomeMessage.close();
            }

        }

        onVisibleChanged: {
            if (!dialogWelcomeMessage.visible && dialogWelcomeMessage.msg_id) {
                if (checkboxShowAgain.checked) {
                    py.call('backend.set_welcome_message_read', [dialogWelcomeMessage.msg_id]);
                }
                if(currentWelcomeMessage +1 !== welcomeMessages.length) {
                    currentWelcomeMessage += 1;
                    showWelcomeMessage(currentWelcomeMessage);
                }

            }
        }
    }

    Dialog {
        id: dialogOptions
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
                    dialogOptions.close();
                    dialogDesign.show();
                }
            }

            Button {
                text: "Über MyGUS"
                onClicked: {
                    dialogOptions.close();
                    showAbout();
                }
            }

            Button {
                text: "Abbrechen"
                onClicked: {
                    dialogOptions.close();
                }
            }

        }
    }

    Dialog {
        id: dialogDesign
        title: "Design"

        positiveButtonText: "Fertig"


        MenuField {
            id: selection
            model: ["Primärfarbe", "Akzentfarbe"]
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
                            }
                        }
                    }
                }
            }
        }

        onRejected: {
            theme.primaryColor = lastPrimaryColor;
            theme.accentColor = lastAccentColor;
            theme.backgroundColor = lastBackgroundColor;
        }

        onAccepted: {
            lastPrimaryColor = "" + theme.primaryColor;
            lastAccentColor = "" + theme.accentColor;
            lastBackgroundColor = "" + theme.backgroundColor;
            py.call("backend.save_theme", [lastPrimaryColor, lastAccentColor, lastBackgroundColor], function callback(result) {})
        }

    }

    ActionButton {
        property bool showing: !navDrawer.showing && pageStack.currentItem === mainPage && !dialogShowing

        anchors {
            right: parent.right
            margins: Units.dp(32)
        }
        y: showing ? parent.height - height - anchors.margins : parent.height

        Behavior on y {
            NumberAnimation {
                property: "y"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }


        iconName: "action/info"
        onClicked: {
            showInformation();
        }
    }

    Snackbar {
        id: snackbar
    }

    LoadingIndicator {
        id: loadingIndicator
        anchors.centerIn: parent
    }

    Python {
        id: py
        Component.onCompleted: {
            snackbar.open("Willkommen zu MyGUS");
            // Add the directory of this .qml file to the search path
            addImportPath(Qt.resolvedUrl("."));
            //androidIconsWorkaround.visible = false;
            importModule_sync('backend');
            load_theme();
            load();
        }

        onError: console.log('error in python: ' + traceback);
    }

    Component.onCompleted: {
        fixDensity();
        mainWindow.visible = true;
    }

}
