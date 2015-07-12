import QtQuick 2.0
import Material 0.1

Page {
    property Component webview
    property Item webview_news

    id: page_news
    title: if (webview_news.loadProgress < 100) { "Lädt " + webview_news.loadProgress.toString() + '% ...' } else { "News" }
    Component.onCompleted: {
        if (Qt.platform.os === "android") {
            webview = Qt.createComponent("android_webview.qml");
        }

        else {
            webview = Qt.createComponent("ubuntu_webview.qml");
        }

        webview_news = webview.createObject(page_news);
        webview_news.url = "http://www.gymnasium-unterrieden.de";
    }
}

