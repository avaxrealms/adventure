const fs = require('fs');
const sharp = require('sharp');

function displayImage(name, uri) {
  svgDataToFile(uri, name + ".svg");
  svgToPng(name);
}

function decodeUri(uri) {
  b64 = uri.split(',')[1];
  let buff = Buffer.from(b64, 'base64');
  return buff.toString('ascii');
}

function svgDataToFile(uri, filename) {
  b64 = uri.split(',')[1];
  let buff = Buffer.from(b64, 'base64');
  let ascii = buff.toString('ascii');
  fs.writeFileSync(filename, ascii);
}

function svgToPng(filename) {
  sharp(filename + ".svg")
    .png()
    .toFile(filename + ".png")
    .then(async function(info) {
      console.png(require('fs').readFileSync(filename + '.png'));
    })
    .catch(function(err) {
      console.log(err);
    });
}

async function uriToImage(name, uri) {
    let decoded = decodeUri(uri);
    let parsed = JSON.parse(decoded);
    console.log(decoded);

    displayImage(name, parsed["image"]);
}

module.exports = {
  displayImage,
  decodeUri,
  svgDataToFile,
  svgToPng,
  uriToImage
}
