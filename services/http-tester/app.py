#!/usr/bin/env python

import http.server
import os

port = os.getenv('HTTP_TESTER_PORT', 8000)

class Handler(http.server.SimpleHTTPRequestHandler):

    def do_GET(self):
        print(self.headers)
        self.super().do_GET()


httpd = http.server.HTTPServer(('', port),  Handler)
httpd.serve_forever()
