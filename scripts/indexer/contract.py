from .event import Event

class Contract:
    # TODO Load ABI from file based on config
    def __init__(self, config, abi, web3):
        self._config = config
        self.name = config["name"]
        self._address = config["address"]
        self._contract = web3.eth.contract(self._address, abi=abi)

        self.events = [Event(x, self) for x in config["events"]]

    def filters(self):
        return [ x.filter() for x in self.events ]

    def filter_for_event(event_name):
        event = Event(event_name)
        # TODO Wrap event in class, load optional fromBlock/sinceBlock
        return event.createFilter(fromBlock=0)
