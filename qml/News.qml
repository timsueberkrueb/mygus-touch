import QtQuick 2.0
import Material 0.1

Page {
    property Component webview
    property Item webviewNews

    id: page_news
    title: if (webviewNews.loadProgress < 100) { "Lädt " + webviewNews.loadProgress.toString() + '% ...' } else { "News" }
    Component.onCompleted: {
        if (Qt.platform.os === "android") {
            webview = Qt.createComponent("AndroidWebview.qml");
        }

        else {
            webview = Qt.createComponent("UbuntuWebview.qml");
        }

        webviewNews = webview.createObject(page_news);
        webviewNews.url = "http://www.gymnasium-unterrieden.de";
    }
}

