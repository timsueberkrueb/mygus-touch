import QtQuick 2.0
import Material 0.1

Page {
    property Component webview
    property Item webview_mensa

    id: page_mensa
    title: if (webview_mensa.loadProgress < 100) { "Lädt " + webview_mensa.loadProgress.toString() + '% ...' } else { "GUS Mensa System" }
    Component.onCompleted: {
        if (Qt.platform.os === "android") {
            webview = Qt.createComponent("AndroidWebview.qml");
        }

        else {
            webview = Qt.createComponent("UbuntuWebview.qml");
        }

        webview_mensa = webview.createObject(page_mensa);
        webview_mensa.url = "https://gus.sams-on.de";
    }
}
