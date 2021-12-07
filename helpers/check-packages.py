#!/usr/bin/env python3
"""This script verifies compiled packages. This implements checks for:
* collision between packages providing same files
"""
import io
import sys
import argparse
import tarfile
import functools
import itertools
from pathlib import Path


def indexread(index):
    """Reader of index file that provides access to parsed index.
    """
    pkg = {}
    last = None
    end = 0
    for line in index:
        line = line.rstrip()
        if line == "":
            end += 1
        elif line[0] == ' ' and last:
            if end:  # We eat empty lines so we should append them back
                pkg[last] += '\n' * end
            pkg[last] += '\n' + line[1:]
            end = 0
        elif ':' in line:
            if end:
                yield pkg
                pkg = {}
            attr, value = line.split(':', maxsplit=1)
            pkg[attr] = value.strip()
            last = attr
            end = 0
        else:
            raise ValueError(f"Invalid index line: {line}")
    yield pkg


@functools.lru_cache(None)
def packages(repo):
    """Index of all packages
    """
    res = {}
    for index in repo.glob('**/Packages'):
        with open(index) as file:
            for pkg in indexread(file):
                assert 'Feed' not in pkg
                assert pkg['Package'] not in res, f"Duplicate package {pkg['Package']}"  # There are none by OpenWrt design
                pkg['Feed'] = index.parent.name
                pkg['Conflicts'] = [name.strip() for name in pkg['Conflicts'].split(',')] if 'Conflicts' in pkg else []
                res[pkg['Package']] = pkg
    return res


@functools.lru_cache(None)
def pkgcontent(pkg):
    """Reads info from ipk file.
    """
    res = {}
    with tarfile.open(pkg) as ipk:
        with tarfile.open(fileobj=ipk.extractfile('./control.tar.gz')) as control:
            res['control'] = next(indexread(io.TextIOWrapper(control.extractfile('./control'))))
            res['files'] = tuple((line.split(' ', maxsplit=1)[1].strip()
                                  for line in io.TextIOWrapper(control.extractfile('./files-sha256sum'))))
    return res


@functools.lru_cache(None)
def fstree(repo):
    """Collects all files packages provide and their owners.
    """
    res = {}
    for pkg in repo.glob('**/*.ipk'):
        content = pkgcontent(pkg)
        for file in content['files']:
            if file not in res:
                res[file] = set()
            res[file].add(content['control']['Package'])
    return res


def check_conflicts(repo):
    """Perform check for files collisions between packages.
    The packages that provide same file need to have conflict specified between them.
    """
    res = True
    index = packages(repo)
    for file, pkgs in fstree(repo).items():
        if len(pkgs) == 1:
            continue  # Ignore packages owned by single package
        for pkga, pkgb in itertools.combinations(pkgs, 2):
            if pkga not in index[pkgb]['Conflicts'] and pkgb not in index[pkga]['Conflicts']:
                print(f"Packages '{pkga}' and '{pkgb}' do not conflict while providing same file: {file}")
                res = False
    return res


def parse_arguments():
    """Parse script arguments
    """
    parser = argparse.ArgumentParser(description="Repository checker")
    parser.add_argument('REPO', nargs='?', default='.', help='Path to repositories to verify')
    parser.add_argument('--all', '-a', action='store_true', help='Run all checks')
    parser.add_argument('--conflicts', action='store_true', help='Check for conflicts between packages')
    return parser.parse_args(), parser


def main():
    args, args_parser = parse_arguments()
    repo = Path(args.REPO)

    fail = None
    if args.all or args.conflicts:
        fail = fail or not check_conflicts(repo)
    if fail is None:
        print("At least one check has to be selected.")
        args_parser.print_usage()

    return not fail


if __name__ == '__main__':
    sys.exit(0 if main() else 1)
