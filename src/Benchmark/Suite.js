"use strict";

exports._copy = function(suite){
  return suite.copy;
};

exports.runST = function(f) {
  return f;
};
