#! /usr/bin/env python3

import argparse
import os
import subprocess
import sys
import yaml

from pathlib import Path
from jinja2 import Template
from pprint import pprint


MACROS = '''
{% macro all_volumes() %}
    {%- for v in volumes -%}
    - {{ v }}:/service-config/{{ v }}
    {% endfor -%}
{% endmacro -%}

{% macro all_servers() %}
    {%- for v in http_ports -%}
    - {{ v }}
    {% endfor -%}
{% endmacro -%}
'''

class Builder:

    def __init__(self, conf):
        self._conf = conf
        with open(os.path.join('apps', f'{conf.app}.yml')) as file:
            self._app = yaml.safe_load(file)

    def run(self):
        self._errors = 0
        self._build()
        self._deploy()

    def _error(self, condition, msg):
        if condition:
            self._errors += 1
            print(f"***** {msg}")
        return condition

    def _check_errors(self):
        if self._errors > 0:
            print("***** ERRORS in spec - aborting.")
            sys.exit(1)

    def _read_specs(self, services, **args):
        specs = dict()
        vols = list()
        ports = dict()
        for service in services:
            try:
                file_name = os.path.join('services', service, 'compose.yml')
                with open(file_name) as file:
                    template = Template(MACROS + '\n' + file.read())
                    # print('>'*50, template.render(services=services, **args))
                    spec = yaml.safe_load(template.render(services=services, **args))
                    vols.extend([ v.split(':')[0] for v in spec.get('volumes') or [] ])
                    self._error(not isinstance(spec, dict), f"Malformed compose specifiation for {service}")
                    specs[service] = spec
            except FileNotFoundError:
                self._error(True, f"No 'compose.yml' file for service {service} ({file_name})")
            else:
                self._check_errors()
                if 'build' in spec and 'image' in spec:
                    print(f"service {service}: found 'build' and 'image' directives - building & ignoring image")
                    spec.pop('image', None)
                if spec.get('build'):
                    spec['build'] = os.path.join('services', service)
                if spec.get('http_port'):
                    ports[service] = (spec['http_port'], spec.get('network_mode') == 'host')
                    spec.pop('http_port', None)
        self._check_errors()
        args['services'] = services
        args['volumes'] = list(set(vols))
        args['http_ports'] = ports
        return (specs, args)
    def _build(self):
        errors = 0

        # secrets
        for name in [ '/service-config/config/.secrets.yaml', 
                      '~/Documents/service-config/config/.secrets.yaml' ]:
            name = os.path.expanduser(name)
            if os.path.exists(name):
                with open(name) as file:
                    secrets = yaml.safe_load(file)
                    print(f"read secrets from {name}")
                    break
        else:
            print("***** .secrets.yaml not found --- aborting")
            sys.exit(1)

        # services used by app
        services = self._app.get('services')
        
        # pass 1: extract volumes from compose.yml files
        specs, args = self._read_specs(services, secrets=secrets, volumes=[], http_ports={})

        # pass 2: process compose.yml files with correct volumes data
        specs, args = self._read_specs(**args)

        # assemble docker-compose.yml
        dc = dict()
        dc['version'] = '2'
        dc['services'] = specs
        # balena needs listing of all volumes
        volumes = args['volumes']
        if len(volumes) > 0: dc['volumes'] = dict.fromkeys(volumes)
        # add path to volumes (when running with docker rather than balena)
        volumes_dir = self._app.get('volumes_dir')
        if volumes_dir:
            for spec in specs.values():
                if spec.get('volumes'):
                    spec['volumes'] = list(set([ os.path.join(volumes_dir, v) for v in spec.get('volumes') ]))
                    for v in spec.get('volumes'):
                        p, _ = v.split(':')
                        Path(p).mkdir(parents=True, exist_ok=True)
        # write docker-compose.yml
        def represent_none(self, _):
            return self.represent_scalar('tag:yaml.org,2002:null', '')
        yaml.add_representer(type(None), represent_none)

        with open(f'docker-compose.yml', 'w') as file:
            file.write(f"# MACHINE GENERATED from {conf.app} - DO NOT EDIT\n\n")   
            yaml.dump(dc, file, default_flow_style=False, sort_keys=False)

    def _deploy(self):
        if self._conf.action == 'none':
            return
        if not self._app.get('fleets'):
            return
        for fleet in self._app.get('fleets'):
            try:
                print(f"{'-'*30} {self._conf.action} to fleet {fleet}")
                nocache = '--nocache' if conf.nocache else ''
                cmd = [ 'balena', self._conf.action, fleet ]
                if conf.nocache: cmd.append('--nocache')
                if conf.debug: cmd.append('--debug')
                print(f"{' '.join(cmd)}")
                subprocess.run(cmd, check=True)
            except subprocess.CalledProcessError:
                print(f"***** {self._conf.action} to {fleet} failed")
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
    parser.add_argument('action', default='deploy', nargs='?',
                        help='deploy (default), build or none')
    parser.add_argument('--tag', default=None,
                        help='optional balena release tag')
    parser.add_argument('--nocache', action='store_true',
                        help="don't use previously built images when building the app")
    parser.add_argument('--debug', '-d', action='store_true',
                        help="print debugging output")
    return parser.parse_args()


if __name__ == '__main__':
    conf = args(sys.argv)
    print(conf)
    builder = Builder(args(sys.argv))
    builder.run()
