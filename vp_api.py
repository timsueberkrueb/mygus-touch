# -*- coding: utf-8 -*-

"""
    Python API for Dominik Stillers Vertretungsplan Solutions
    (C) Tim Sueberkrueb, 2015

    *** Releases and Changes ***
    0.1.0       Basic functionality
    0.1.1       Added python 2.7 support
    0.1.2       Authentication via App Id and Token added
    0.1.3       Authentication key moved to private file
"""
__author__ = 'Tim Süberkrüb'
__version__ = '0.1.3'


try:
    import urllib.request as urllib
except ImportError:
    import urllib2 as urllib
import json
import authentication

server_ip = 'dominik-stiller.de'
server_port = '12566'
app_id = 'sueberkrueb'
access_token = authentication.vp_api_access_token


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


def get_url(command, data=None, indent=False):
    global server_ip, server_port, app_id, access_token
    url = ''
    if command == 'dates':
        url = 'dates'
    elif command == 'data':
        url = "data/" + data.get("date")
    elif command == 'latestversion':
        url = "latestversion/" + data.get("date")
    elif command == 'serverstate':
        url = "serverstate"
    elif command == 'apiversion':
        url = "apiversion"
    elif command == 'dataupdated':
        url = "dataupdated"
    url = "http://" + server_ip + ":" + server_port + "/" + url + "?appid=" + app_id + "&accesstoken=" + access_token
    if (indent):
        url += "?indent";
    return url


def get_json(url):
    data = urllib.urlopen(url)
    json = data.read().decode('utf-8')
    return json


def get_dict(text):
    return json.loads(text)


def get(command,
            data=None, indent=False):
    return get_dict(get_json(get_url(command, data, indent)))


def get_dates():
    d = get('dates')
    dates = d['data']['dates']
    return dates


def get_data(date):
    data = Data(date=date)
    d = get('data', data)['data']
    return d


def get_latestversion(date):
    data = Data(date=date)
    d = get('latestversion', data)['data']
    return d


def get_serverstate():
    d = get('serverstate')
    state = d['data']['serverState']
    return state


def get_apiversion():
    d = get('apiversion')
    v = d['data']['version']
    return v


def get_dataupdated():
    d = get('dataupdated')
    date = d['data']
    return date


''' High Level Access '''


class Plan:
    def __init__(self, date):
        self.date = date
        self.data = None
        self.latestversion = None

        self.version = None
        self.last_updated = None
        self.notes = None
        self.absent_classes = None
        self.absent_courses = None
        self.absent_teachers = None
        self.missing_rooms = None

        self.entries = None

        self.load()

    def load(self):
        data = get_data(self.date)

        meta = data['metadata']
        self.version = meta['version']
        self.last_updated = meta['lastUpdated']
        self.notes = meta['notes'].replace("\t", "\n").replace("LFLF", '\n')
        self.absent_classes = meta['absentClasses']
        self.absent_courses = meta['absentCourses']
        self.absent_teachers = meta['absentTeachers']
        self.missing_rooms = meta['missingRooms']

        self.entries = data['entries']

        self.latestversion = get_latestversion(self.date)

    def get_relevant_entries_by_form(self, form):
        e = []
        f = [form[:-1], form[-1]]
        for entry in self.entries:
            if entry['className'].lower() == form or (entry['className'].lower().startswith(f[0]) and entry['className'].lower().count(f[1])>0)\
                    or entry['className'] == f[0]:
                e += [entry]
        return e

    def get_entries_by_lesson(self, form):
        entries = self.get_relevant_entries_by_form(form)
        e = {}
        for entry in entries:
            if entry['lesson'] not in e.keys():
                e[entry['lesson']] = list()
            e[entry['lesson']] += [entry]
        return e


def get_plans():
    dates = get_dates()
    plans = dict()
    for date in dates:
        plans[date] = Plan(date)
    return plans
