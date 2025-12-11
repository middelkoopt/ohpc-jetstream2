#!/usr/bin/python3

import sys
import logging
import argparse
import tomllib
from pprint import pprint, pformat

log = logging.getLogger()

def main(argv):
    parser = argparse.ArgumentParser(
        prog='run.py',
        description='Iterate over all configurations')
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--config', default='run.ini')
    parser.add_argument('--all', action='store_true')

    parser.add_argument('--dist', action='append')
    parser.add_argument('--release', action='append')
    parser.add_argument('--script', action='append')

    args = parser.parse_args(argv)

    if args.debug:
        log.setLevel(logging.DEBUG)

    log.info("=== run.py")
    log.debug("argv:%s", argv)

    with open(args.config,'rb') as f:
        config = tomllib.load(f)

    ## Build plan
    runs=[]

    ## All combinations
    if args.all:
        for dist, property in config['dist'].items():
            if not property.get('enabled', True):
                continue
            release = property.get('release')
            if type(release) == str:
                release = [ release ]
            for r in release:
                run={}
                run['family'] = property.get('family')
                run['dist'] = dist
                run['release'] = r
                runs.append(run)
    else:
        for dist in args.dist or config['default']['dist']:
            property = config['dist'][dist]
            for r in args.release or property['release']:
                run={}
                run['family'] = property.get('family')
                run['dist'] = dist
                run['release'] = r
                runs.append(run)

    log.debug("runs>>\n%s", pformat(runs))

    for run in runs:
        for script in args.script or config['default']['script']:
            template = config['script'][script]['run']
            log.debug("run: %s %s", template, run)
            execute = template.format(**run)
            log.info("run: %s", execute)

    log.debug('exiting')
    return 0

if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)05s %(message)s',level=logging.INFO)
    sys.exit(main(sys.argv[1:]))
