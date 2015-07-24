import QtQuick 2.0
import io.thp.pyotherside 1.4

Python {
    id: py
    Component.onCompleted: {
        snackbar.open("Willkommen zu MyGUS");
        // Add the directory of this .qml file to the search path
        addImportPath(Qt.resolvedUrl('.'));
        importModule_sync('main');
    }

    onError: console.log('error in python: ' + traceback);
}
