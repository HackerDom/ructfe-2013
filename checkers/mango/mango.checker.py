import argparse
import sys
import requests

port = 8081
status_codes = {'OK': 101, 'CORRUPT': 102, 'MUMBLE': 103, 'DOWN':104, 'CHECKER_ERROR': 110}

def check(hostname):
    return status_codes['OK']
    
def get(hostname, id, flag):
    payload = ({'id': id})
    r = requests.get("http://%s:%s/" % (hostname, str(port)), params = payload)
    print r.url
    print r.status_code
    print r.text
    sys.stderr.write("Status code = %d\n" % r.status_code)
    if r.status_code == 200:
        return status_codes['OK']
    elif r.status_code == 404:
        return status_codes['CORRUPT']
    elif r.status_code == 500:
        return status_codes['DOWN']
    else:
        return status_codes['MUMBLE']
    
def put(hostname, id, flag):
    payload = ({'id': id, 'flag': flag})
    r = requests.post("http://%s:%s/" % (hostname, str(port)), params = payload)
    print r.status_code
    print r.text
    sys.stderr.write("Status code = %d\n" % r.status_code)
    #sys.stdout.write("Flag was put with id=%s", )
    if r.status_code == 200:
        return status_codes['OK']
    elif r.status_code in [404, 500]:
        return status_codes['CORRUPT']
    else:
        return status_codes['MUMBLE']
    
def main():
    if args.mode == 'get':
        return get(args.hostname, args.id, args.flag)
    elif args.mode == 'put':
        return put(args.hostname, args.id, args.flag)
    elif args.mode == 'check':
        return check(args.hostname)
    else:
        return status_codes['CHECKER_ERROR']
        
parser = argparse.ArgumentParser(description='mongo srv checker')
parser.add_argument(dest='mode', action='store')
parser.add_argument(dest='hostname', action='store')
parser.add_argument(dest='id', action='store', nargs = '?', default = '')
parser.add_argument(dest='flag', action='store', nargs = '?', default = '')

args = parser.parse_args()

print "mode:" + args.mode
print "hostname:" + args.hostname
print "id:" + args.id
print "flag:" + args.flag

result = main()
print result
sys.exit(result)