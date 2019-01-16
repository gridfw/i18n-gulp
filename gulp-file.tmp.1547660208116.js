var PluginError, cliTable, coffeescript, compileCoffee, errorHandler, gulp, gutil, include, rename, uglify, watch;

gulp = require('gulp');

gutil = require('gulp-util');

// minify		= require 'gulp-minify'
include = require("gulp-include");

uglify = require('gulp-uglify-es').default;

rename = require("gulp-rename");

coffeescript = require('gulp-coffeescript');

PluginError = gulp.PluginError;

cliTable = require('cli-table');

// compile final values (consts to be remplaced at compile time)
// handlers
compileCoffee = function() {
  // include related files
  return gulp.src('assets/index.coffee').pipe(include({
    hardFail: true
  // convert to js
  })).pipe(coffeescript({
    bare: true
  // uglify when prod mode
  // save 
  }).on('error', errorHandler)).pipe(uglify()).pipe(gulp.dest('build')).on('error', errorHandler);
};

// watch files
watch = function() {
  gulp.watch(['assets/**/*.coffee'], compileCoffee);
};

// error handler
errorHandler = function(err) {
  var code, col, expr, line, ref, table;
  // get error line
  expr = /:(\d+):(\d+):/.exec(err.stack);
  if (expr) {
    line = parseInt(expr[1]);
    col = parseInt(expr[2]);
    code = (ref = err.code) != null ? ref.split("\n").slice(line - 3, line + 3).join("\n") : void 0;
  } else {
    code = line = col = '??';
  }
  // Render
  table = new cliTable();
  table.push({
    Name: err.name
  }, {
    Filename: err.filename
  }, {
    Message: err.message
  }, {
    Line: line
  }, {
    Col: col
  });
  console.error(table.toString());
  console.log('\x1b[31mStack:');
  console.error('\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐');
  console.error('\x1b[34m', err.stack);
  console.log('\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘');
  console.log('\x1b[31mCode:');
  console.error('\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐');
  console.error('\x1b[34m', code);
  console.log('\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘');
};

// default task
gulp.task('default', gulp.series(compileCoffee, watch));
