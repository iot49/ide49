#! /usr/bin/env python3

import argparse
import os
import re
import subprocess
import sys
import yaml

from jq import jq
from pprint import pprint


ALL = 'ALL'                          # all volumes

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

    def _build(self):
        errors = 0

        # secrets
        try:
            with open(os.path.expanduser('~/.secrets.yaml')) as file:
                secrets = yaml.safe_load(file)
        except FileNotFoundError:
            secrets = {}
      
        # services included in app
        services = jq('.app.services').transform(self._app)
        
        # gather compose specs
        specs = dict()
        for service in services:
            try:
                file_name = os.path.join('services', service, 'compose.yml')
                with open(file_name) as file:
                    spec = yaml.safe_load(file)
                    specs = {**specs, **spec}
            except FileNotFoundError:
                self._error(True, f"No 'compose.yml' file for service {service} ({file_name})")
            else:
                self._error(len(spec) != 1, f"Expecting one compose specification in {file_name}") or \
                self._error(list(spec.keys())[0] != service, f"Service name mismatch in {file_name}: {list(spec.keys())[0]} != {service}") or \
                self._error(not isinstance(spec[service], dict), f"Malformed compose specifiation for {service}")
                self._check_errors()
                spec = spec[service]
                self._error('build' in spec and 'image' in spec, f"Only one of 'build' or 'image' permitted in compose specification for {service}")
                if 'build' in spec:
                    self._error('image' in spec, f"Only either 'build' or 'image' permitted in compose specification for {service}")
                    self._error(spec['build'] != '.', f"Build argument not '.' for {service}")
                    spec['build'] = os.path.join('services', service)
                else:
                    self._error(not 'image' in spec, f"Either 'build' or 'image' must be present in compose specifiaction for {service}")
                # substitute secrets
                if 'environment' in spec:
                    env = spec.get('environment', [])
                    if isinstance(spec['environment'], dict):
                        # convert to array form
                        spec['environment'] = { f"{k}={v}" for k,v in spec['environment'].items() }
                    def sub(e):
                        z = re.match(r'.*!secret\s([\w\d_]*)', e)
                        if z:
                            for g in z.groups():
                                if not g in secrets:
                                    self._error(f"unknown secret {g} in {file_name}")
                                e = re.sub(f'!secret\s{g}', secrets[g], e)
                        return e
                    spec['environment'] = list(map(sub, env))
        self._check_errors()

        # volumes used by selected services
        volumes = jq("to_entries | map(.value.volumes) | flatten").transform(specs)
        volumes = { v.split(':')[0] for v in volumes if v }
        if ALL in volumes: volumes.remove(ALL)

        # process ALL volumes specs
        for s in specs.values():
            for i, v in enumerate(s.get('volumes', [])):
                if v.startswith(ALL):
                    root_dir = v.split(':')[1]
                    del s['volumes'][i]
                    for v in volumes:
                        s['volumes'].append(f"{v}:{root_dir}/{v}")
                    # remove duplicates
                    s['volumes'] = list(set(s['volumes']))


        # assemble docker-compose.yml
        dc = dict()
        dc['version'] = 2
        dc['volumes'] = dict.fromkeys(volumes)
        dc['services'] = specs

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
        for fleet in jq('.app.fleets').transform(self._app):
            try:
                print(f"{'-'*30} Push to fleet {fleet}")
                nocache = '--nocache' if conf.nocache else ''
                # cmd = [ 'balena', 'push', fleet ]
                cmd = [ 'balena', 'push', fleet ]
                if conf.nocache: cmd.append('--nocache')
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

    return parser.parse_args()


if __name__ == '__main__':
    conf = args(sys.argv)
    builder = Builder(args(sys.argv))
    builder.run()
