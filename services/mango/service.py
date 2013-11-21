from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import os
import pymongo
import urlparse
from bson.objectid import ObjectId
import json
 
def connect_db():
    from pymongo import MongoClient
    client = MongoClient('localhost', 27017)
    return client.mydb
 
def add_by_id(id, flag, db):
    flags = db.flags
    flag_id = flags.insert({"_id": id, "flag": flag})
    print flag_id
    return True
 
def add(flag, db):
    flags = db.flags
    flag_id = flags.insert({"flag": flag})
    print flag_id
    return flag_id
 
def get_by_id(id, db):
    flags = db.flags
    found = flags.find_one({"_id" : id})
    print "found: " + str(found)
    print type(found)
    return found
 
class MonHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            parsed = urlparse.urlparse(self.path)
            p = urlparse.parse_qs(parsed.query)
            id = p['id'][0]
            db = connect_db()
            flag = get_by_id(id, db)
            print flag
            print type(flag)
            self.send_response(200)
            self.send_header('Content-type','text-html')
            self.end_headers()
            self.wfile.write(flag["flag"])
            return
           
        except IOError:
            self.send_error(404)
    def do_POST(self):
        try:
            parsed = urlparse.urlparse(self.path)
            p = urlparse.parse_qs(parsed.query)
            id = p['id'][0]
            flag = p['flag'][0]
            db = connect_db()
            result = add_by_id(id, flag, db)
            if result:
                self.send_response(200)
            else:
                self.send_response(500)

            self.send_header('Content-type','text-html')
            self.end_headers()
            self.wfile.write(result)
            return
           
        except IOError:
            self.send_error(404)
   
def run():
    print('http server is starting...')
    server_address = ('127.0.0.1', 8081)
    httpd = HTTPServer(server_address, MonHTTPRequestHandler)
    print('http server is running...')
    httpd.serve_forever()
   
if __name__ == '__main__':
    run()