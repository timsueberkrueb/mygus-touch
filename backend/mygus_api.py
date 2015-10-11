# -*- coding: utf-8 -*-

"""
    Python API for MyGUS web services
    (C) Tim Sueberkrueb, 2015

    *** Releases and Changes ***
    0.1.0       Basic functionality
    0.1.1       Login API now online thanks to Julian Schließus
                Added MD5-Encryption
    0.1.2       Support for teacher api thanks to Julian Schließus
    0.1.3       Added fallback servers
"""
__author__ = 'Tim Süberkrüb'
__version__ = '0.1.3'

try:
    import urllib.request as urllib
except ImportError:
    import urllib2 as urllib
import json
import hashlib
import datetime
from . import authentication

server_address_student_login = authentication.default_login_server + '/login-schueler.php'
server_address_teacher_login = authentication.default_login_server + '/teacher/login-lehrer.php'
server_address_welcome_messages = authentication.messages_server + '/message/message.php'
password_salt = authentication.mygus_api_password_salt


def check_servers():
    global server_address_student_login, server_address_teacher_login
    try:
        # Standard server available
        json.loads(urllib.urlopen('http://' + server_address_student_login))
    except Exception as e:
        # Using fallback server
        print("Standard server unreachable, using fallback server")
        server_address_student_login = authentication.fallback_login_server + '/login-schueler.php'
        server_address_teacher_login = authentication.fallback_login_server + '/teacher/login-lehrer.php'

def check_connection():
    try:
        urllib.urlopen('http://74.125.228.100', timeout=1)
        return True
    except Exception as e:
        print('An Exception has occurred while checking internet connection: ' + str(e))
        return False


''' General Server Commmunication '''


class Data():
    def __init__(self, **kwargs):
        self.data = kwargs

    def get(self, name):
        return self.data[name]

    def set(self, name, value):
        self.data[name] = value

    def configure(self, **kwargs):
        self.data.update(kwargs)


def get_url(username, key, action, login_mode=0, user_name=None, app_id=None, app_version=None, app_platform=None):
    global server_address_student_login
    global server_address_teacher_login
    if login_mode == 0:     # student authentication
        url = "http://" + server_address_student_login + '?class={}&password={}&action={}'.format(username, key, action)
    else:                   # teacher authentication
        url = "http://" + server_address_teacher_login + '?username={}&password={}&action={}'.format(username, key, action)
    if user_name:
        url += '&user_name={}'.format(user_name)
    if app_id:
        url += '&app_id={}'.format(app_id)
    if app_version:
        url += '&app_version={}'.format(app_version)
    if app_platform:
        url += '&app_platform={}'.format(app_platform)
    return url


def get_json(url):
    data = urllib.urlopen(url)
    json = data.read().decode('utf-8')
    return json


def get_dict(text):
    return json.loads(text)


def get(username, key, action, login_mode=0, user_name=None, app_id=None, app_version=None, app_platform=None):
    return get_dict(get_json(get_url(username, key, action, login_mode, user_name, app_id, app_version, app_platform)))


def get_password_hash(password):
    global password_salt
    m = hashlib.md5()
    m.update((password_salt + password).encode('utf-8'))
    return m.hexdigest()


def get_date_today():
    return datetime.date.today()


def get_date_today_str():
    d = datetime.date.today().timetuple()
    date = "{}.{}.{}".format(str(d[2]), str(d[1]), str(d[0]))
    return date


""" App interface """


def authenticate(username, password, login_mode=0, user_name=None, app_id=None, app_version=None, app_platform=None):
    password_hash = get_password_hash(password)
    d = get(username, password_hash, 'authenticate', login_mode, user_name, app_id, app_version, app_platform)
    if d["error"]:
        return False
    return d['response']


def get_timetable(form, key, user_name=None, app_id=None, app_version=None, app_platform=None):
    d = get(form, key, 'get_timetable', user_name, app_id, app_version, app_platform)
    if d["error"]:
        raise Exception(d["error"])
    return d['response']


def get_welcome_messages(form, read_messages, app_version, app_platform):
    url = "http://" + server_address_welcome_messages
    data = urllib.urlopen(url)
    text = data.read().decode('utf-8').replace('\r', '')
    d = json.loads(text)
    messages = []
    for message in d['messages']:
        if message['id'] not in read_messages:
            s = message['expiration_date'].split('.')
            expiration_date = datetime.date(int(s[2]), int(s[1]), int(s[0]))
            today_date = get_date_today()
            if today_date <= expiration_date:
                conditional_expression = message['conditional_expression'].replace('[$form]', repr(form)).\
                                                                           replace('[$app_platform]', repr(app_platform)).\
                                                                           replace('[$app_version]', repr(app_version))
                if eval(conditional_expression):
                    messages += [message]
    return messages
