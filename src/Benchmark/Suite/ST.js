/* This module contains only _unsafe_ functions that mutate the original suite.
 */

"use strict";

var isBrowser = typeof window !== 'undefined'
    && ({}).toString.call(window) === '[object Window]';

// If it's a browser environment, then we skip require and assume that
// Benchmark.js has been included as a script tag.
var Benchmark = isBrowser ? window.Benchmark : require('benchmark');

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

// Benchmark.Suite.prototype.on(type, listener)
exports.on2 = function(suite) {
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

exports.accumulateResults = function(suite){
  return function(cb){
    return function(){
      var results = [];
      suite.on("cycle", function(e){
	results.push(e.target);
      });
      suite.on("complete", function(e){
	cb(results)();
      });
    };
  };
};
