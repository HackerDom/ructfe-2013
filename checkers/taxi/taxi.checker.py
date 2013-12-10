#!/usr/bin/python
import argparse
import sys
import requests
import ast
import random
import string
import math
import uuid
import re

from random import randrange

port = 8081
status_codes = {'OK': 101, 'CORRUPT': 102, 'MUMBLE': 103, 'DOWN':104, 'CHECKER_ERROR': 110}

def generate_id():
    #todo: generate 32-c string
    return uuid.uuid4()

def gen_flag():
    res = ''.join(random.choice(string.ascii_uppercase + string.digits) for i in range(31))
    res += "="
    return res

def gen_user_name():
    res = ''.join(random.choice(string.ascii_lowercase) for i in range(random.randrange(3, 12)))
    res = random.choice(string.ascii_uppercase) + res
    return res

def gen_admin_name():
    res = ''.join(random.choice(string.ascii_lowercase) for i in range(random.randrange(3, 12)))
    res += ''.join(random.choice(string.digits) for i in range(random.randrange(2, 6)))
    return res

def gen_route():
    #todo: add streets names
    res = ''.join(random.choice(string.ascii_lowercase) for i in range(random.randrange(3, 12)))
    res = random.choice(string.ascii_uppercase) + res
    res += ', '
    res += ''.join(random.choice(string.digits) for i in range(random.randrange(2, 6)))
    res += ' - '
    res += random.choice(string.ascii_uppercase) + ''.join(random.choice(string.ascii_lowercase) for i in range(random.randrange(3, 12)))
    res += ', '
    res += ''.join(random.choice(string.digits) for i in range(random.randrange(2, 6)))
    return res

def register_admin(hostname, attempts):
    for i in range(0, attempts):
        admin = gen_admin_name()
        payload = ({'admin': admin})
        r = requests.post("http://%s:%s/add_admin/" % (hostname, str(port)), params = payload)
        if r.status_code == 200:
            if 'hm' in r.cookies:
                return admin, r.cookies['hm']
    return "", ""

def pack_id(id, admin, hm):
    return id + "+" + admin + "+" + hm

def unpack_id(id):
    values = id.split("+")
    return values[0], values[1], values[2]

def check(hostname):
    admin, h_mac = register_admin(hostname, 3)

    if admin == "" or h_mac == "":
        return status_codes['CORRUPT']

    id = generate_id()
    user = gen_user_name()
    route1 = gen_route()
    amount1 = randrange(10) * 100

    cookies = dict(hm=h_mac)

    payload = ({'id': id,  'amount': amount1, 'admin': admin, 'user': user, 'route': route1})
    r = requests.post("http://%s:%s/add_route/" % (hostname, str(port)), params=payload, cookies=cookies)
    print >> sys.stderr, r.url + "; " + str(r.status_code) + "; " + r.text
    if r.status_code != 200:
        return status_codes['CORRUPT']

    id = generate_id()
    route2 = gen_route()
    amount2 = randrange(10) * 100

    payload = ({'id': id,  'amount': amount2, 'admin': admin, 'user': user, 'route': route2})
    r = requests.post("http://%s:%s/add_route/" % (hostname, str(port)), params=payload, cookies=cookies)
    print >> sys.stderr, r.url + "; " + str(r.status_code) + "; " + r.text
    if r.status_code != 200:
        return status_codes['CORRUPT']

    payload = ({'admin': admin})
    r = requests.get("http://%s:%s/amount/" % (hostname, str(port)), params=payload, cookies=cookies)
    print >> sys.stderr, r.url + "; " + str(r.status_code) + "; " + r.text
    if r.status_code == 200:
        res = ast.literal_eval(r.text)
        if 'value' in res.keys():
            calc_value = (amount1 + amount2) / 1.1
            value = float(res['value'])
            if math.fabs(calc_value - value) < 0.01:
                return status_codes['OK']
            else:
                return status_codes['CORRUPT']
        else:
            return status_codes['MUMBLE']
    else:
        return status_codes['CORRUPT']

def get(hostname, id, flag):
    try:
        actual_id, admin, h_mac = unpack_id(id)
    except:
        return status_codes['CHECKER_ERROR']

    payload = ({'id' : actual_id, 'admin': admin})
    cookies = dict(hm=h_mac)
    r = requests.get("http://%s:%s/route/" % (hostname, str(port)), params = payload, cookies=cookies)

    print >> sys.stderr, r.url + "; " + str(r.status_code) + "; " + r.text
    if r.status_code == 200:
        res = ast.literal_eval(r.text)
        #for key in res:
        #    print key + ": " + res[key]
        if 'route' in res.keys() and res['route'] == flag:
            return status_codes['OK']
        else:
            return status_codes['CORRUPT']
    elif r.status_code == 404:
        return status_codes['CORRUPT']
    elif r.status_code == 500:
        return status_codes['DOWN']
    else:
        return status_codes['MUMBLE']

def put(hostname, id, flag):
    admin, h_mac = register_admin(hostname, 3)

    if admin == "" or h_mac == "":
        return status_codes['CORRUPT']

    user = gen_user_name()
    payload = ({'id': id,  'amount': randrange(10) * 100, 'admin': admin, 'user': user, 'route': flag})

    cookies = dict(hm=h_mac)

    r = requests.post("http://%s:%s/add_route/" % (hostname, str(port)), params=payload, cookies=cookies)
    print >> sys.stderr, "Response: " + str(r.status_code) + "; Id = " + r.text
    if r.status_code == 200:
        lines = r.text.split('\r\n')
        for l in lines:
            m = re.match('(.)*(?=HTTP\/)', l)
            if m:
                id_sent = m.group()
                break

        new_id = pack_id(id_sent, admin, h_mac)
        print >> sys.stdout, new_id
        return status_codes['OK']
    elif r.status_code in [404, 500]:
        return status_codes['CORRUPT']
    else:
        return status_codes['MUMBLE']
    
def main():
    try:
        if args.mode == 'get':
            return get(args.hostname, args.id, args.flag)
        elif args.mode == 'put':
            return put(args.hostname, args.id, args.flag)
        elif args.mode == 'check':
            return check(args.hostname)
        else:
            return status_codes['CHECKER_ERROR']
    except requests.exceptions.ConnectionError:
        return status_codes["DOWN"]
        
parser = argparse.ArgumentParser(description='taxi srv checker')
parser.add_argument(dest='mode', action='store')
parser.add_argument(dest='hostname', action='store')
parser.add_argument(dest='id', action='store', nargs = '?', default = '')
parser.add_argument(dest='flag', action='store', nargs = '?', default = '')

args = parser.parse_args()

result = main()
print >> sys.stderr, result
sys.exit(result)