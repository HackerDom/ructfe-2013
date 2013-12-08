#!/usr/bin/python2
import time
import BaseHTTPServer
import urlparse
from Crypto.Cipher import AES

HOST_NAME = '0.0.0.0'
PORT_NUMBER = 4369

class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            try:
                self.messages
            except AttributeError as e:
                self.messages = {}
                try:
                    with open("messages", "r") as fm:
                        for line in fm.readlines():
                            (id, enc_mes) = line.rstrip().split("\t")
                            self.messages[id] = enc_mes
                except IOError:
                    pass
                self.snapshot = open("messages", "a")


            parsed_path = urlparse.urlparse(self.path)
            parsed_qs = urlparse.parse_qs(parsed_path.query)

            if parsed_path.path == "/list":
                result = self.list()
            elif parsed_path.path == "/get":
                id = parsed_qs["id"][0]
                key = parsed_qs["key"][0]
                result = self.get(id, key)
            elif parsed_path.path == "/put":
                mes = parsed_qs["mes"][0]
                result = self.put(mes)
            else:
                self.send_response(404)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                return

            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()

            self.wfile.write(result)

        except Exception as e:
            self.send_response(500)
            self.send_header("Content-type", "text/plain")
            self.end_headers()

            self.wfile.write("Exception!\n")
            self.wfile.write(e) 
            return 



    def list(self):
        return "\n".join(["\t".join([key,value]) for (key,value) in self.messages.items()])

    def get(self, id, key_hex):
        enc_hex = self.messages[id]
        mes = CryptoHelper.decrypt(enc_hex.decode("HEX"), key_hex.decode("HEX"))
        return mes

    def put(self, mes):
        with open("/dev/random", "rb") as f:
            key = f.read(32)
            id = f.read(8).encode("HEX")

        enc = CryptoHelper.encrypt(mes, key).encode("HEX")
        self.messages[id] = enc
        self.snapshot.write("\t".join([id, enc]) + "\n")
        self.snapshot.flush()

        return "\t".join([id, key.encode("HEX")])

class CryptoHelper:

    IV = 'S3cr3t_IV TRY_ME'

    @staticmethod
    def encrypt(message, key):
        message = CryptoHelper.padPKCS7(message)
        aes = AES.new(key, AES.MODE_CBC, CryptoHelper.IV)
        ciphertext = aes.encrypt(message)
        return ciphertext

    @staticmethod
    def padPKCS7(message):
        length = 16 - (len(message) % 16)
        message += chr(length)*length
        return message

    @staticmethod
    def decrypt(ciphertext, key):
        aes = AES.new(key, AES.MODE_CBC, CryptoHelper.IV)
        message = aes.decrypt(ciphertext)
        message = CryptoHelper.unpadPKCS7(message)
        return message

    @staticmethod
    def unpadPKCS7(message):
        if len(message)%16 or not message:
            raise ValueError("Invalid message len")
        padlen = ord(message[-1])
        if padlen > 16:
            raise ValueError("Invalid padding")
        for i in range(padlen):
            if ord(message[-(i + 1)]) != padlen:
                raise ValueError("Invalid padding")
        return message[:-padlen]

if __name__ == '__main__':
    print "Server init..."
    httpd = BaseHTTPServer.HTTPServer((HOST_NAME, PORT_NUMBER), MyHandler)

    print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)
