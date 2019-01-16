###*
 * This contains methods used inside i18n source locals
###
i18n = 
	switch: (attr, cases)->
		throw new Error "Illegal switch arg" unless typeof attr is 'string' or Array.isArray(attr) and attr.every (el)-> typeof el is 'string'
		throw new Error "Illegal switch cases" unless typeof cases is 'object' and cases
		throw new Error '"else" options is required on switch cases' unless 'else' of cases
		# convert attr into path
		attr = attr.split '.' if typeof attr is 'string'
		# return
		[I18N_SYMBOL]: 'switch'
		m: 'switch'
		s: attr # switch attribute or path
		c: cases # cases

	###*
	 * Compile expression (module or pug)
	###
	compile: (expr)->
		throw new Error 'Illegal arguments' if arguments.length isnt 1
		if typeof expr is 'object'
			throw new Error "Illegal module" unless typeof expr.m is 'string'
			fx= _i18nCompileModules[expr.m]
			throw new Error "Unknown module: #{expr.m}"
			expr = fx
		else if typeof expr is 'string'
			if /[#!]\{/.test expr
				expr = Pug.compileClient expr,
					compileDebug: off
					globals: ['i18n']
					inlineRuntimeFunctions: false
					name: 'ts'
				expr.replace /^function ts/, 'function'
			else
				expr = JSON.stringify Pug.render expr
		else 
			throw new Error "Unsupported expression"


###*
 * Compile modules
###
_i18nCompileModules=
	###
	{
		s: ['path'] # switch path
		c: {} # cases
	}
	###
	switch: (obj)->
		(locals)->
			# get attr
			# attr = locals
			# for k in obj.s
			# 	attr = attr[k]
			# 	break unless attr?
			# # get value
			
			# return