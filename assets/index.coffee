###*
 * Cookie parser for GridFW
 * @copyright khalid RAFIK 2018
###
'use strict'

plugName = require('../package.json').name
gutil	= require 'gulp-util'
Path	= require 'path'
through = require 'through2'
Pug		= require 'pug'
Terser	= require 'terser'

I18N_SYMBOL = Symbol 'i18n module'

#=include _noramlize.coffee
#=include _compile-methods.coffee

# gulp compile files
gulpCompiler = (options)->
	bufferedI18n = Object.create null
	baseDir = __dirname
	# options
	options ?= Object.create null
	toJson = options.json is true
	# compile each file
	bufferContents = (file, end, cb)->
		# ignore incorrect files
		return cb() if file.isNull()
		return cb new Error "i18n-compiler>> Streaming isn't supported" if file.isStream()
		# process
		err = null
		try
			# compile file and buffer data
			Object.assign bufferedI18n, eval file.contents.toString 'utf8'
			# base dir
			baseDir = file._base
		catch e
			err = new gutil.PluginError plugName, e
		cb err
	# concat all files
	concatAll = (cb)->
		err= null
		try
			# normalize 18n: convert into separated locals
			data = _normalize bufferedI18n
			# separate into multiple locals
			for k,v of data
				# compile to JSON
				if toJson
					fle = new gutil.File
						path: Path.join baseDir, '..', k + '.json'
						contents: new Buffer JSON.stringify v
				# compile js instead
				else
					content = []
					for a,b of v
						content.push "#{JSON.stringify a}:#{(i18n.compile b).toString()}"
					# create table for fast access
					content = """
					var msgs= exports.messages= {#{content.join ','}};
					var arr= exports.arr= [];
					var map= exports.map= Object.create(null);
					var i=0, k;
					for(k in msgs){ arr.push(msgs[k]); map[k] = i++; }
					"""
					# create file
					fle = new gutil.File
						path: Path.join baseDir, '..', k + '.js'
						contents: new Buffer content
				@push fle
		catch e
			err = new gutil.PluginError plugName, e
		cb err
		


	# return
	through.obj bufferContents, concatAll
module.exports = gulpCompiler
