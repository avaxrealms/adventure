"""
Package: N/A
Filename: run_myth.py
Author(s): chazu

Run mythril

"""

# Python imports

# Our imports

# Third-party imports

import os

contracts = []

def add_contract(subpath, filename: str):
    contracts.append({"subpath": subpath, "filename": filename})


add_contract("core", "adventure.sol")
add_contract(None, "plunder.sol")
add_contract("core", "RGold.sol")
add_contract("core", "attributes.sol")
add_contract("dungeon", "snowbridge.sol")
add_contract("core", "attacher.sol")


for contract in contracts:
    print(f"Running against {contract}")
    output_path = f"flattened/{contract['filename']}"
    if contract['subpath']:
        os.system(f"npx hardhat flatten contracts/{contract['subpath']}/{contract['filename']} > {output_path}")
    else:
        os.system(f"npx hardhat flatten contracts/{contract['filename']} > {output_path}")

    # TODO remove all SPDX shit from flattened
    with open(output_path, "r") as f:
        lines = f.readlines()
    with open(output_path, "w") as f:
        for line in lines:
            if not "SPDX" in line:
                f.write(line)
    os.system(f"slither flattened/{contract['filename']} > scans/{contract['filename']}.slither 2>&1")


    #os.system(f"myth a flattened/{output_filename} > scans/{output_filename}.myth")
