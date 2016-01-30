# -*- coding: utf-8 -*-

__author__ = 'Tim Süberkrüb'
__version__ = '0.2.7'


import pyotherside
from . import vp_api
from . import dirty_auth
import pickle
import urllib.error
import datetime
import os
import platform


plans = {}
app_id = 'mygus'
try:
    APP_ID = os.environ['APP_ID']
    APP_PKGNAME = APP_ID.split('_')[0]
    app_path = os.environ['XDG_DATA_HOME'] + '/' + APP_PKGNAME + '/'
    app_platform = 'ubuntu-touch'
except KeyError:
    app_path = './'
    app_platform = 'android'
app_version = __version__
user_name = 'unknown'
read_welcome_messages = []
user_full_name = ''
is_teacher = False


def load():
    global plans
    global user_name
    global app_path
    global read_welcome_messages
    global user_full_name
    try:
        with open(app_path + 'plans.bin', 'rb') as file:
            plans = pickle.load(file)
    except FileNotFoundError:
        pass
    username = ""
    password = ""
    user_full_name = ""
    login_mode = 0
    try:
        with open(app_path + 'login.bin', 'rb') as file:
            username = pickle.load(file)
            password = pickle.load(file)
            login_mode = pickle.load(file)
    except FileNotFoundError:
        pass

    try:
        with open(app_path + 'welcome_messages.bin', 'rb') as file:
            read_welcome_messages = pickle.load(file)
    except FileNotFoundError:
        pass

    try:
        with open(app_path + 'user_full_name.bin', 'rb') as file:
            user_full_name = pickle.load(file)
    except FileNotFoundError:
        pass

    result = dict()
    result["username"] = username
    user_name = username
    result["password"] = password
    result["login_mode"] = login_mode
    result["full_name"] = user_full_name
    result['dates'] = sorted(list(plans.keys()))

    # Check servers
    #mygus_api.check_servers()

    return result


def refresh():
    global plans
    global app_path

    result = dict(error=False)
    try:
        dates = vp_api.get_dates()
        result["dates"] = dates
        plans = vp_api.get_plans()

        with open(app_path + 'plans.bin', 'wb') as file:
            pickle.dump(plans, file)

        return result
    except urllib.error.URLError:
        result["error"] = True
        return result


def login(username, password, login_mode, name=None):
    global user_name
    global app_id
    global app_version
    global app_platform
    global app_path
    global user_full_name
    global is_teacher
    is_teacher =  login_mode == 1
    user_full_name = name
    try:
        user_name = username
        result = dirty_auth.authenticate(username, password, login_mode, user_name, app_id, app_version, app_platform)
        with open(app_path + 'login.bin', 'wb') as file:
            pickle.dump(username, file)
            pickle.dump(password, file)
            pickle.dump(login_mode, file)
        with open(app_path + 'user_full_name.bin', 'wb') as file:
            pickle.dump(user_full_name, file)
        return result
    except urllib.error.URLError:
        return 'NETWORK_ERROR'


def date_changed(date):
    global plans
    result = dict()
    current_plan = plans[date]
    result["model"] = current_plan.entries  # Standard model for students plan
    result["model_teachers"] = sorted([entry for entry in current_plan.entries if entry['substitutionTeacher'] not in
                                                                                ['-', 'entfällt']],
                                      key=lambda k: k['substitutionTeacher']) # Teachers model

    info = """Version: {}
Zuletzt aktualisiert: {}
Abwesende Klassen: {}
Abwesende Kurse: {}
Abwesende Lehrer: {}
Fehlende Räume: {}
Bemerkungen: {}

    """.format(current_plan.version,
               current_plan.last_updated,
               ''.join(c + ', ' for c in current_plan.absent_classes)[:-2] if current_plan.absent_classes else ' -',
               ''.join(c + ', ' for c in current_plan.absent_courses)[:-2] if current_plan.absent_courses else ' -',
               ''.join(c + ', ' for c in current_plan.absent_teachers)[:-2] if current_plan.absent_teachers else ' -',
               ''.join(c + ', ' for c in current_plan.missing_rooms)[:-2] if current_plan.missing_rooms else ' -',
               current_plan.student_notes if current_plan.student_notes else ' -')
    result["information"] = info
    result['version'] = current_plan.version
    result['absent_classes'] = ''.join(c + ',\n' for c in current_plan.absent_classes)[:-2] if current_plan.absent_classes else ' -'
    result['absent_courses'] = ''.join(c + ',\n' for c in current_plan.absent_courses)[:-2] if current_plan.absent_courses else ' -'
    result['absent_teachers'] = ''.join(c + ',\n' for c in current_plan.absent_teachers)[:-2] if current_plan.absent_teachers else ' -'
    result['missing_rooms'] = ''.join(c + ',\n' for c in current_plan.missing_rooms)[:-2] if current_plan.missing_rooms else ' -'
    result['student_notes'] = current_plan.student_notes if current_plan.student_notes else ' -'
    result['teacher_notes'] = current_plan.teacher_notes if current_plan.teacher_notes else ' -'
    result['relevant_entries'] = current_plan.get_relevant_entries_for_teacher(user_full_name) if is_teacher else current_plan.get_relevant_entries_by_form(user_name)
    split_date = date.split('.')
    d = datetime.date(int(split_date[2]), int(split_date[1]), int(split_date[0]))
    result["weekday"] = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'][d.weekday()]
    return result


def load_theme():
    global app_path
    result = dict(error=False)
    try:
        with open(app_path + 'theme.bin', 'rb') as file:
            result["primary_color"] = pickle.load(file)
            result["accent_color"] = pickle.load(file)
            result["background_color"] = pickle.load(file)
    except:
        result["error"] = True
    return result

def save_theme(primary_color, accent_color, background_color):
    global app_path
    with open(app_path + 'theme.bin', 'wb') as file:
        pickle.dump(primary_color, file)
        pickle.dump(accent_color, file)
        pickle.dump(background_color, file)


def exit():
    print("Exiting ...")


def get_welcome_messages():
    global read_welcome_messages
    global user_name
    global app_version
    global app_platform
    return [] #mygus_api.get_welcome_messages(user_name, read_welcome_messages, app_version, app_platform)


def set_welcome_message_read(id):
    global read_welcome_messages
    read_welcome_messages += [id]
    with open(app_path + 'welcome_messages.bin', 'wb') as file:
        pickle.dump(read_welcome_messages, file)


print('Python loaded')
pyotherside.atexit(exit)
