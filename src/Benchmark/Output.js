"use strict";

exports.toStringAndLog = function(benchmarkResult){
  return function() {
    console.log(String(benchmarkResult));
  }
}

exports.fillSpace = function(desiredLength){
  return function(str) {
    var len = desiredLength - str.length;
    for (var i = len - 1; i >= 0; i--) str += ' ';
    return str;
  }
}

/* We can assume than one column is always less than 80 characters in length,
 * otherwise it will not be readable anyway. This means that we can use this
 * classic hack for ultra fast string creation.
 */
var line = "--------------------------------------------------------------------------------";
exports.createLine = function(len){
  return line.substring(0, len);
}
