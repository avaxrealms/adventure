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

deploying = [
    "core/adventure.sol",
    #"core/plunder.sol",
    "core/RGold.sol",
    "core/attributes.sol",
    "dungeon/snowbridge.sol",
    "core/attacher.sol"
]

for contract in deploying:
    output_filename = contract.split("/")[1]
    print(f"Running against {contract}")
    # os.system(f"npx hardhat flatten contracts/{contract} > flattened/{output_filename}")

    os.system(f"slither flattened/{output_filename} > scans/{output_filename}")
