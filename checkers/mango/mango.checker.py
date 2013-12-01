import argparse
import sys
import requests
import uuid
import ast

port = 8081
status_codes = {'OK': 101, 'CORRUPT': 102, 'MUMBLE': 103, 'DOWN':104, 'CHECKER_ERROR': 110}

def check(hostname):
    return status_codes['OK']
    
def get(hostname, id, flag, admin):
    payload = ({'id' : id, 'admin': admin})
    r = requests.get("http://%s:%s/route/" % (hostname, str(port)), params = payload)
    print >> sys.stderr, r.url + "; " + str(r.status_code) + "; " + r.text
    if r.status_code == 200:
        res = ast.literal_eval(r.text)
        #for key in res:
        #    print key + ": " + res[key]
        if res.has_key('route') and res['route'] == flag:
            return status_codes['OK']
        else:
            return status_codes['CORRUPT']
    elif r.status_code == 404:
        return status_codes['CORRUPT']
    elif r.status_code == 500:
        return status_codes['DOWN']
    else:
        return status_codes['MUMBLE']
    
def put(hostname, id, flag, admin, user):
    from random import randrange
    payload = ({'id': id,  'amount': randrange(10) * 100, 'admin': admin, 'user': user, 'route': flag})
    r = requests.post("http://%s:%s/add_route/" % (hostname, str(port)), params=payload)
    print >> sys.stderr, str(r.status_code) + "; " + r.text
    if r.status_code == 200:
        if r.text != id:
            print >> sys.stdout, r.text
        return status_codes['OK']
    elif r.status_code in [404, 500]:
        return status_codes['CORRUPT']
    else:
        return status_codes['MUMBLE']
    
def main():
    #todo: admin!
    try:
        if args.mode == 'get':
            return get(args.hostname, args.id, args.flag, "Vova")
        elif args.mode == 'put':
            return put(args.hostname, args.id, args.flag, "Vova", "Ksenya")
        elif args.mode == 'check':
            return check(args.hostname)
        else:
            return status_codes['CHECKER_ERROR']
    except requests.exceptions.ConnectionError:
        return status_codes["DOWN"]
        
parser = argparse.ArgumentParser(description='mongo srv checker')
parser.add_argument(dest='mode', action='store')
parser.add_argument(dest='hostname', action='store')
parser.add_argument(dest='id', action='store', nargs = '?', default = '')
parser.add_argument(dest='flag', action='store', nargs = '?', default = '')

args = parser.parse_args()

result = main()
print >> sys.stderr, result
sys.exit(result)