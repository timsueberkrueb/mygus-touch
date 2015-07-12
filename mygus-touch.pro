TEMPLATE = app

QT += qml quick widgets svg xml
QT += androidextras


QTPLUGIN += qsvg

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    android/AndroidManifest.xml \
    android/res/values/libs.xml \
    android/build.gradle

OTHER_FILES += \
    android/AndroidManifest.xml


ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android


HEADERS +=
