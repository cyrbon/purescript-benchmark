"use strict";

exports.fn1 = function(fn) {
  return function(a) {
    return function() {
      fn(a);
    };
  };
}
