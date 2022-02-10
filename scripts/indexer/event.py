class Event:
    def __init__(self, config, contract):
        self._config = config
        self.name = config["name"]
        self.fromBlock = config["fromBlock"] if "fromBlock" in config.keys() else 0
        self._contract = contract

    def filter(self):
        return self._contract._contract.events.__dict__[self.name].createFilter(fromBlock=0)
