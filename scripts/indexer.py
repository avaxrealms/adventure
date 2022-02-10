"""
Package: N/A
Filename: indexer.py
Author(s): Goss
"""

# Python imports
import asyncio
import json

# Our imports
from indexer.contract import Contract
# Third-party imports
import yaml
from web3 import Web3

web3 = Web3(Web3.HTTPProvider("http://localhost:8545"))
config = yaml.load(open("config.yaml").read(), Loader=yaml.CLoader)
abi = json.loads(open("artifacts/contracts/core/adventure.sol/Adventure.json").read())["abi"]

contracts = []

# Wrap all contracts from config
for contract in config["contracts"]:
    contracts.append(Contract(contract, abi, web3))

# add your blockchain connection information
web3 = Web3(Web3.HTTPProvider("http://localhost:8545"))

# define function to handle events and print to the console
def handle_event(event):
    print(Web3.toJSON(event))

async def log_loop(event_filter, poll_interval):
    while True:
        for summoned in event_filter.get_new_entries():
            handle_event(summoned)
        await asyncio.sleep(poll_interval)

def main():
    loop_filters = []
    loop = asyncio.get_event_loop()

    for contract in contracts:
        for event in contract.events:
            loop_filters.append(event.filter())

    try:
        callbacks = [log_loop(filter, 2) for filter in loop_filters]
        loop.run_until_complete(
            asyncio.gather(*callbacks)
        )
    finally:
        loop.close()

if __name__ == "__main__":
    main()
