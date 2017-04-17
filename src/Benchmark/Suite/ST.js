/* This module contains only _unsafe_ functions that mutate the original suite.
 */

"use strict";

var Benchmark = require('benchmark');

exports["new"] = function() {
  return new Benchmark.Suite();
};

// Benchmark.Suite.prototype.add(name, fn [, options={}])
exports.add = function(suite) {
  return function (name) {
    return function (fn) {
      return function() {
	suite.add(name, fn);
      };
    };
  };
};

// Benchmark.Suite.prototype.run([options={}])
exports.run = function(suite) {
  return function(){
    suite.run();
  };
}

// Benchmark.Suite.prototype.on(type, listener)
exports.on = function(suite) {
  return function(type) {
    return function(listener) {
      return function() {
	suite.on(type, function(e) {
	  listener(e)();
	});
      };
    };
  };
}
