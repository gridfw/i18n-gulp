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

I18N_SYMBOL = Symbol 'i18n module'

#=include _noramlize.coffee
#=include _compile-methods.coffee

# gulp compile files
gulpCompiler = (options)->
	bufferedI18n = Object.create null
	baseDir = __dirname
	# options
	options ?= Object.create null
	doCompilePug = 'compilePug' of options
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
				# compile to pug
				if doCompilePug
					content = []
					vv= {}
					for a,b of v
						vv[a] = i18n.compile b
						content.push "#{JSON.stringify a}:#{(i18n.compile b).toString()}"
					console.log '===> ', vv
					# create file
					fle = new gutil.File
						path: Path.join baseDir, '..', k + '.js'
						contents: new Buffer "{#{content.join ','}}"
				# compile to JSON instead
				else
					fle = new gutil.File
						path: Path.join baseDir, '..', k + '.json'
						contents: new Buffer SON.stringify v
				@push fle
		catch e
			err = new gutil.PluginError plugName, e
		cb err
		


	# return
	through.obj bufferContents, concatAll
module.exports = gulpCompiler