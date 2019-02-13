gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
uglify			= require('gulp-uglify-es').default
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'

GfwCompiler		= require 'gridfw-compiler'

#=include assets/_error-handler.coffee
settings=
	mode: gutil.env.mode || 'dev'
	isProd: gutil.env.mode is 'prod'

# compile final values (consts to be remplaced at compile time)
# handlers
compileCoffee = ->
	gulp.src 'assets/index.coffee'
		# include related files
		.pipe include hardFail: true
		# template
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		# convert to js
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		# uglify when prod mode
		.pipe uglify()
		# save 
		.pipe gulp.dest 'build'
		.on 'error', GfwCompiler.logError
# watch files
watch = (cb)->
	unless settings.isProd
		gulp.watch ['assets/**/*.coffee'], compileCoffee
	cb()
	return

# default task
gulp.task 'default', gulp.series compileCoffee, watch