#! /usr/bin/env python3

import argparse
import os
import subprocess
import sys
import yaml

from jinja2 import Template
from pprint import pprint


MACROS = '''
{% macro all_volumes() %}
    {% for v in volumes %}
    - {{ v }}:/service-config/{{ v }}
    {% endfor %}
{% endmacro %}
'''

class Builder:

    def __init__(self, conf):
        self._conf = conf
        with open(os.path.join('apps', f'{conf.app}.yml')) as file:
            self._app = yaml.safe_load(file)

    def run(self):
        self._errors = 0
        self._build()
        self._push()

    def _error(self, condition, msg):
        if condition:
            self._errors += 1
            print(f"***** {msg}")
        return condition

    def _check_errors(self):
        if self._errors > 0:
            print("***** ERRORS in spec - aborting.")
            sys.exit(1)

    def _read_specs(self, services, secrets, volumes=[], http_ports={}):
        specs = dict()
        vols = list()
        http_p = dict()
        for service in services:
            try:
                file_name = os.path.join('services', service, 'compose.yml')
                with open(file_name) as file:                    
                    spec = yaml.safe_load(Template(MACROS + '\n' + file.read()).render(services=services, volumes=volumes, secrets=secrets, http_ports=http_ports))
                    vols.extend([ v.split(':')[0] for v in spec.get('volumes') or [] ])
                    self._error(not isinstance(spec, dict), f"Malformed compose specifiation for {service}")
                    specs[service] = spec
            except FileNotFoundError:
                self._error(True, f"No 'compose.yml' file for service {service} ({file_name})")
            else:
                self._check_errors()
                self._error('build' in spec and 'image' in spec, f"Only one of 'build' or 'image' permitted in compose specification for {service}")
                if 'build' in spec:
                    self._error('image' in spec, f"Only either 'build' or 'image' permitted in compose specification for {service}")
                    self._error(spec['build'] != '.', f"Build argument not '.' for {service}")
                    spec['build'] = os.path.join('services', service)
                else:
                    self._error(not 'image' in spec, f"Either 'build' or 'image' must be present in compose specifiaction for {service}")
                    if spec.get('http_port'):
                        http_p[service] = (spec['http_port'], spec.get('network_mode') == 'host')
        self._check_errors()
        return (specs, list(set(vols)), http_p)
 
    def _build(self):
        errors = 0

        # secrets
        try:
            with open(os.path.expanduser('~/.secrets.yaml')) as file:
                secrets = yaml.safe_load(file)
        except FileNotFoundError:
            secrets = {}
      
        # services used by app
        services = self._app.get('app').get('services')
        
        # pass 1: extract volumes from compose.yml files
        specs, volumes, http_ports = self._read_specs(services, secrets)
        
        # pass 2: process compose.yml files with correct volumes data
        specs, _, _ = self._read_specs(services, secrets, volumes, http_ports)
        pprint(http_ports)

        # assemble docker-compose.yml
        dc = dict()
        dc['version'] = 2
        if len(volumes) > 0: dc['volumes'] = dict.fromkeys(volumes)
        svcs = {}
        for k, v in specs.items():
            v.pop('http_port', None)
            svcs[k] = v
        dc['services'] = svcs

        # write docker-compose.yml
        def represent_none(self, _):
            return self.represent_scalar('tag:yaml.org,2002:null', '')
        yaml.add_representer(type(None), represent_none)

        with open(f'docker-compose.yml', 'w') as file:
            file.write(f"# MACHINE GENERATED from {conf.app} - DO NOT EDIT\n\n")   
            yaml.dump(dc, file, default_flow_style=False, sort_keys=False)

    def _push(self):
        if self._conf.nopush:
            return
        for fleet in self._app.get('app').get('fleets'):
            try:
                print(f"{'-'*30} Push to fleet {fleet}")
                nocache = '--nocache' if conf.nocache else ''
                cmd = [ 'balena', 'push', fleet ]
                if conf.nocache: cmd.append('--nocache')
                if conf.debug: cmd.append('--debug')
                subprocess.run(cmd, check=True)
            except subprocess.CalledProcessError:
                print(f"***** push to {fleet} failed")
                sys.exit(1)
            if not conf.tag: continue
            ps = subprocess.Popen(('balena', 'releases', fleet), stdout=subprocess.PIPE)
            release = subprocess.check_output(('awk', 'NR==2 {print $1}'), stdin=ps.stdout)
            ps.wait()
            release = release.decode().strip()
            os.system(f"balena tag set {conf.tag} --release {release}")


def args(argv):
    parser = argparse.ArgumentParser(description='Assemble docker app from spec file and compose-template and push to balena fleet')
    parser.add_argument('app',
                        help='app specification in app/ folder')
    parser.add_argument('--tag', default=None,
                        help='optional balena release tag')
    parser.add_argument('--nopush', action='store_true',
                        help="skip pushing to fleet if set")
    parser.add_argument('--nocache', action='store_true',
                        help="don't use previously built images when building the app")
    parser.add_argument('--debug', '-d', action='store_true',
                        help="print debugging output")
    return parser.parse_args()


if __name__ == '__main__':
    conf = args(sys.argv)
    builder = Builder(args(sys.argv))
    builder.run()
