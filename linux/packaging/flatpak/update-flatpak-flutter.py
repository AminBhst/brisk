#!/usr/bin/env python3

import argparse
import yaml

def update_brisk_tag_commit(filename, new_tag, new_commit):
    with open(filename, 'r') as f:
        data = yaml.safe_load(f)

    updated = False
    for module in data.get('modules', []):
        if isinstance(module, dict):
            for source in module.get('sources', []):
                if (
                    isinstance(source, dict) and
                    source.get('type') == 'git' and
                    source.get('url') == 'https://github.com/BrisklyDev/brisk.git'
                ):
                    source['tag'] = new_tag
                    source['commit'] = new_commit
                    updated = True

    if not updated:
        print("No matching Brisk source found to update.")
        return

    with open(filename, 'w') as f:
        yaml.dump(data, f, sort_keys=False)
    print(f"✅ Updated Brisk source with tag={new_tag}, commit={new_commit}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='YAML file to update')
    parser.add_argument('--tag', required=True, help='New tag to set')
    parser.add_argument('--commit', required=True, help='New commit hash to set')
    args = parser.parse_args()

    update_brisk_tag_commit(args.file, args.tag, args.commit)
