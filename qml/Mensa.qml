import QtQuick 2.4
import Material 0.2

Page {
    property Component webview
    property Item webviewMensa

    id: page_mensa
    title: if (webviewMensa.loadProgress < 100) { "Lädt " + webviewMensa.loadProgress.toString() + '% ...' } else { "GUS Mensa System" }
    Component.onCompleted: {
        if (Qt.platform.os === "android") {
            webview = Qt.createComponent("AndroidWebview.qml");
        }

        else {
            webview = Qt.createComponent("UbuntuWebview.qml");
        }

        webviewMensa = webview.createObject(page_mensa);
        webviewMensa.url = "https://gus.sams-on.de";
    }
}
