#!/usr/bin/env python

import http.server
import os

port = int(os.getenv('HTTP_TESTER_PORT', 8000))

class Handler(http.server.SimpleHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/text')
        self.end_headers()

        self.wfile.write(f"Request Line: {self.requestline}\n\n".encode())

        self.wfile.write(f"Client Address: {self.client_address}\n\n".encode())

        self.wfile.write(b"Request Headers\n")
        self.wfile.write(b"===============\n\n")
        for k,v in self.headers.items():
            self.wfile.write(f"{k}: {v}\n".encode())


httpd = http.server.HTTPServer(('', port),  Handler)
httpd.serve_forever()
