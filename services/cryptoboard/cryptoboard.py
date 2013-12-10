#!/usr/bin/python2
import time
import BaseHTTPServer
import urlparse
from Crypto.Cipher import AES

HOST_NAME = '0.0.0.0'
PORT_NUMBER = 4369

messages = None
keys = None

class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def do_GET(self):
        global messages, snapshotMessages, keys, snapshotKeys

        try:
            if messages is None:
                messages = {}
                try:
                    with open("messages", "r") as fm:
                        for line in fm.readlines():
                            (id, enc_mes) = line.rstrip().split(" ")
                            messages[id] = enc_mes
                except IOError:
                    pass
                snapshotMessages = open("messages", "a")
            if keys is None:
                keys = {}
                try:
                    with open("keys", "r") as fk:
                        for line in fk.readlines():
                            (id, key) = line.rstrip().split(" ")
                            keys[id] = key
                except IOError:
                    pass
                snapshotKeys = open("keys", "a")


            parsed_path = urlparse.urlparse(self.path)
            parsed_qs = urlparse.parse_qs(parsed_path.query)

            if parsed_path.path == "/list":
                result = self.list()
            elif parsed_path.path == "/get":
                id = parsed_qs["id"][0]
                enc = parsed_qs["enc"][0]
                result = self.get(id, enc)
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
        return "\n".join(value for value in messages.values())

    def get(self, id_hex, enc_hex):
        key_hex = keys[id_hex]
        mes = CryptoHelper.decrypt(enc_hex.decode("HEX"), key_hex.decode("HEX"))
        return mes

    def put(self, mes):
        with open("/proc/random", "rb") as f:
            key = f.read(32)
            id_hex = f.read(8).encode("HEX")

        enc_hex = CryptoHelper.encrypt(mes, key).encode("HEX")
        messages[id_hex] = enc_hex
        snapshotMessages.write(" ".join([id_hex, enc_hex]) + "\n")
        snapshotMessages.flush()

        key_hex = key.encode("HEX")
        keys[id_hex] = key_hex
        snapshotKeys.write(" ".join([id_hex, key_hex]) + "\n")
        snapshotKeys.flush()

        return " ".join([id_hex, enc_hex])

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
