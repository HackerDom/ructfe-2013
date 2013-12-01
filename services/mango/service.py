from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import os
import pymongo
from pymongo import collection
import urlparse
from bson.objectid import ObjectId
import json
from datetime import datetime
import uuid

DBNAME = 'taxi'
COLNAME = 'orders'

def connect_db(dbname):
    from pymongo import Connection
    c = Connection()
    return c[dbname]

def generate_id():
    return uuid.uuid4(); #namesp

def add(amount, admin, user, route, col):
    generated_id = generate_id()
    rid = col.insert({"_id": generated_id, "date": datetime.now(), "amount": amount, "admin": admin, "user": user, "route": route})
    print rid
    return rid

def add_by_id(id, amount, admin, user, route, col):
    rid = col.insert({"_id": id, "date": datetime.now(), "amount": amount, "admin": admin, "user": user, "route": route})
    print rid
    return rid

def add_user(uname):
    return True
 
def get_by_id(id, col):
    found = col.find_one({"_id" : id})
    print "found: " + str(found)
    print type(found)
    return found

def get_map_func(admin_name):
    from bson.code import Code
    map_f = "function() { if (this.admin == " + admin_name + ") emit(this.admin, this.amount); }";
    return Code(map_f)

def get_reduce_func():
    from bson.code import Code
    reduce_f = Code("function(key, values) {return Array.sum(values) / 1.1;}")
    return reduce_f

def mr_test(col, admin_name):
    res = col.map_reduce(get_map_func(admin_name), get_reduce_func(),  "res")
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

class MonHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        import os.path
        try:
            parsed = urlparse.urlparse(self.path)
            action = os.path.split(parsed.path)[0]
            action = action.replace('/', '')
            print action
            p = urlparse.parse_qs(parsed.query)
            admin = p['admin'][0]
            db = connect_db(DBNAME)
            col = collection.Collection(db, COLNAME)

            if action == 'route':
                if p.has_key('id'):
                    r_id = p['id'][0]
                    res = get_by_id(r_id, col)
                    result_doc = dict_to_str(res)
                    self.send_response(200)
                    self.send_header('Content-type','text-html')
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
                self.send_response(405) #501?
                return

            self.send_response(200)
            self.send_header('Content-type','text-html')
            self.end_headers()
            self.wfile.write("Results: \n")
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

            if action == 'add_route':
                p = urlparse.parse_qs(parsed.query)
                if p.has_key('id'):
                    o_id = p['id'][0]
                else:
                    o_id = ""
                amount = p['amount'][0]
                admin = p['admin'][0]
                user = p['user'][0]
                route = p['route'][0]
                print "params: " + o_id + "; " + amount
                if o_id == "":
                    result = add(amount, admin, user, route, col)
                else:
                    result = add_by_id(o_id, amount, admin, user, route, col)
            #todo
            elif action == 'add_user':
                p = urlparse.parse_qs(parsed.query)
                u_name = p['name'][0]

                print "params: " + u_name
                #todo
                result = add_user(u_name)
            else:
                self.send_response(405) #501?
                return

            if result is None:
                self.send_response(501)
            else:
                self.send_response(200)

            self.send_header('Content-type','text-html')
            self.end_headers()
            self.wfile.write(result)
            return
           
        except IOError:
            self.send_error(404)
        except KeyError:
            self.send_error(400)
   
def run():
    print('http server is starting...')
    server_address = ('127.0.0.1', 8081)
    httpd = HTTPServer(server_address, MonHTTPRequestHandler)
    print('http server is running...')
    httpd.serve_forever()
   
if __name__ == '__main__':
    run()