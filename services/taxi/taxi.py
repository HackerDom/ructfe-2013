import urlparse
import uuid
import os
import random
import string
import hmac
import hashlib
import os.path

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from pymongo import collection
from pymongo import Connection
from datetime import datetime
from bson.code import Code

DBNAME = 'taxi'
COLNAME = 'orders'
USERS = 'users'
KEY_FILE = 'key'


def connect_db(dbname):
    c = Connection()
    return c[dbname]


def generate_id():
    #todo: generate 32-c string
    return uuid.uuid4()


def add(amount, admin, user, route, col):
    generated_id = generate_id()
    rid = col.insert(
        {"_id": generated_id, "date": datetime.now(), "amount": amount, "admin": admin, "user": user, "route": route})
    print rid
    return rid


def add_by_id(id, amount, admin, user, route, col):
    rid = col.insert(
        {"_id": id, "date": datetime.now(), "amount": amount, "admin": admin, "user": user, "route": route})
    print rid
    return rid


def get_by_id(id, col):
    found = col.find_one({"_id": id})
    print "found: " + str(found)
    print type(found)
    return found


def get_map_func(admin_name):
    map_f = "function() { if (this.admin == '" + admin_name + "') emit(this.admin, this.amount); }"
    return Code(map_f)


def get_reduce_func():
    reduce_f = "function(key, values) {return Array.sum(values) / 1.1;}"
    return Code(reduce_f)


def mr_test(col, admin_name):
    res = col.map_reduce(get_map_func(admin_name), get_reduce_func(), "res")
    results = []
    for doc in res.find():
        print doc
        results.append(doc)
    return results


def view_all(col, admin_name):
    res = col.find({"admin": admin_name}).sort("date")
    results = []
    for doc in res:
        print doc
        results.append(doc)
    return results


def rreplace(s, old, new, occurrence):
    li = s.rsplit(old, occurrence)
    return new.join(li)


def dict_to_str(d):
    res = "{%s}" % ''.join('\'{}\':\'{}\','.format(key, val) for key, val in d.items())
    r = rreplace(res, ',', '', 1)
    return r


def try_create_user(query, db):
    try:
        p = urlparse.parse_qs(query)
        admin = p['admin'][0]
        user = p['user'][0]
        col = collection.Collection(db, USERS)
        admin_exists = col.find_one({"admin": admin})
        if admin_exists is None:
            return "Admin does not  exist"
        user_exists = col.find_one({"user": user})
        if user_exists is not None:
            return "User already exists"
        id = col.insert({"admin": admin, "user": user})
        if id:
            return "Success"
        else:
            return "Can't create new user"
    except KeyError:
        return "You have to set [admin], [user] and [pswd] parameters in order to register new user"


def try_create_admin(query, db):
    try:
        p = urlparse.parse_qs(query)
        admin = p['admin'][0]
        col = collection.Collection(db, USERS)
        admin_exists = col.find_one({"admin": admin})
        if admin_exists is not None:
            return "Admin already exists", ""
        id = col.insert({"admin": admin, "user": admin})
        if id:
            return "Success", admin
        else:
            return "Can't create new admin", ""
    except KeyError:
        return "You have to set [admin] parameter in order to register new admin", ""


def get_hmac(message):
    if not os.path.isfile(KEY_FILE):
        return False

    f = file(KEY_FILE)
    key = f.read()
    print "read key: " + key
    return hmac.new(key, message, digestmod=hashlib.sha1).hexdigest()


class MonHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            parsed = urlparse.urlparse(self.path)
            action = os.path.split(parsed.path)[0]
            action = action.replace('/', '')
            print action
            p = urlparse.parse_qs(parsed.query)
            admin = p['admin'][0]

            db = connect_db(DBNAME)
            col = collection.Collection(db, COLNAME)

            if not 'cookie' in self.headers:
                print "no cookie sent"
                self.send_error(401)
                return
            print self.headers['cookie']
            if not 'hm' in self.headers['cookie']:
                print "no hmac sent"
                self.send_error(401)
                return
            hm = self.headers['cookie']
            h_mac = hm.split("=")

            if h_mac[1] != get_hmac(admin):
                self.send_error(401)
                return

            if action == 'route':
                if 'id' in p.keys():
                    r_id = p['id'][0]
                    res = get_by_id(r_id, col)
                    result_doc = dict_to_str(res)
                    self.send_response(200)
                    self.send_header('Content-type', 'text-html')
                    self.end_headers()
                    self.wfile.write(result_doc)
                    return
                else:
                    self.send_response(400)
                    return
            elif action == 'routes':
                result_doc = view_all(col, admin)
            elif action == 'amount':
                result_doc = mr_test(col, admin)
            else:
                self.send_response(405)
                return

            self.send_response(200)
            self.send_header('Content-type', 'text-html')
            self.end_headers()
            for doc in result_doc:
                self.wfile.write(doc)
                self.wfile.write("\n")
            return

        except IOError:
            self.send_error(404)

    def do_POST(self):
        try:
            parsed = urlparse.urlparse(self.path)
            action = os.path.split(parsed.path)[0]
            action = action.replace('/', '')
            print action
            db = connect_db(DBNAME)
            col = collection.Collection(db, COLNAME)

            if action == 'add_user':
                res = try_create_user(parsed.query, db)
                if res == "Success":
                    #todo: cookie
                    self.send_response(200)
                else:
                    self.send_error(400)
                    self.wfile.write(res)
                return
            elif action == 'add_admin':
                res, admin = try_create_admin(parsed.query, db)
                if res == "Success":
                    self.send_response(200)
                    self.send_header('Set-Cookie', 'hm=' + get_hmac(admin))
                    self.end_headers()
                else:
                    self.send_error(400)
                    self.wfile.write(res)
                return
            elif action == 'add_route':
                #todo: add verifying
                p = urlparse.parse_qs(parsed.query)
                if 'id' in p.keys():
                    o_id = p['id'][0]
                else:
                    o_id = ""

                try:
                    amount = int(p['amount'][0])
                except ValueError:
                    self.send_response(400)
                    return

                admin = p['admin'][0]
                user = p['user'][0]
                route = p['route'][0]
                print "params: " + o_id + "; " + str(amount)
                if o_id == "":
                    result = add(amount, admin, user, route, col)
                else:
                    result = add_by_id(o_id, amount, admin, user, route, col)
                self.send_header('Content-type', 'text-html')
                self.end_headers()
                self.wfile.write(result)
                if result is not None:
                    self.send_response(200)
                else:
                    self.send_response(501)
                return
            else:
                self.send_response(405) #501?
                return

        except IOError:
            print "IOError"
            self.send_error(404)
        except KeyError:
            print "KeyError"
            self.send_error(400)


def gen_key_if_not_exists():
    if os.path.isfile(KEY_FILE):
        return
    length = 256
    chars = string.ascii_letters + string.digits + '!@#$%^&*()'
    random.seed = (os.urandom(1024))
    key = ''.join(random.choice(chars) for i in range(length))
    f = file(KEY_FILE, 'w')
    f.write(key)

def run():
    print 'taxi service is starting...'
    server_address = ('127.0.0.1', 8081)
    httpd = HTTPServer(server_address, MonHTTPRequestHandler)
    print 'Welcome to our taxi service!'
    print 'You can order trips, view your users\' routes and monitor your riding costs'
    print 'Please notice that we charge you extra 10% VAT according to our Ural state laws'
    gen_key_if_not_exists()
    httpd.serve_forever()


if __name__ == '__main__':
    run()