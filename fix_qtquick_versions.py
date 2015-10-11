# -*- coding: utf-8 -*-

"""
* This script fixes QtQuick version numbers of qml-material in order to make it runnable on Ubuntu Touch (Qt 5.3)
* (C) Copyright 2015 by Tim Süberkrüb
"""

__author__ = 'Tim Süberkrüb'
__version__ = '0.1'


import glob


def fix(path, changes):
    print("Getting files to fix ...")
    qml_files = []

    qml_files += [f for f in glob.glob(path + '*.qml')]
    for f in qml_files:
        print("Found " + f)

    print("Making changes ...")
    for filename in qml_files:
        print("Opening file " + filename)
        with open(filename, "r+") as file:
            text = file.read()
            for key in changes:
                print("Changing '" + key + "' to '" + changes[key] + "'")
                while text.find(key) != -1:
                    text = text.replace(key, changes[key])
            file.seek(0)
            file.write(text)
            file.truncate()
        print("Finished")


def fix_material_qtquick_controls_styles():
    changes = {"import QtQuick.Controls.Styles 1.3": "import QtQuick.Controls.Styles 1.2"}
    fix('lib/arm-linux-gnueabihf/QtQuick/Controls/Styles/Material/', changes)

def fix_material():
    changes = {
        "import QtQuick.Controls 1.3": "import QtQuick.Controls 1.2",
        "import QtQuick.Controls.Styles 1.3": "import QtQuick.Controls.Styles 1.2",
    }
    fix('lib/arm-linux-gnueabihf/Material/', changes)

def main():
    print("Fixing QtQuick.Controls.Styles.Material ...")
    fix_material_qtquick_controls_styles()
    print("Fixing Material")
    fix_material()

if __name__ == '__main__':
    main()
