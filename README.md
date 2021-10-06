# Avaxrealms Adventure

## A note on the console helpers

The `extensions` folder contains a little bit of code thats loaded as a hardhat plugin into the console. Essentially, the variable `game` is an instance of the Game class which you see in `extensions/play.js` - yes the name of the file doesn't match, I know.

Anyhow, if you look at the Game class, and the Adventurer class, you'll see how it sets up a basic 'harness' or tool for playing the game from inside the console. It needs work but its a start.

The other thing which makes this work is the change to deploy.js - at the end of the script, it shits out all the addresses of the contracts to `addresses.json` in the root of the project. This is loaded by our Game plugin so that you don't have to map addresses manually.
