"use strict";

exports.toStringAndLog = function(benchmarkResult){
  return function() {
    console.log(String(benchmarkResult));
  }
}
