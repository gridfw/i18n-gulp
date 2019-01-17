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
			throw new Error "Unknown module: #{expr.m}" unless fx
			expr = fx expr
		else if typeof expr is 'string'
			expr = _compileStr expr
		else 
			throw new Error "Unsupported expression"
		return expr

###*
 * Compile strings
 * @return {String | function} - compiled string or function compiler (case of arguments)
###
_compileStr = (expr)->
	expr = '|' + expr.replace /\n/g, "\n|"
	if /[#!]\{/.test expr
		expr = Pug.compileClient expr,
			self:on
			compileDebug: off
			globals: ['i18n']
			inlineRuntimeFunctions: false
			name: 'ts'
		# uglify and remove unused vars
		mnfy = Terser.minify expr
		throw mnfy if mnfy.error
		expr = mnfy.code
		expr = expr.replace /^function ts/, 'function '
	else
		expr = JSON.stringify Pug.render expr
	return expr
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
		# compile
		cases= []
		for k,v of obj.c
			cases.push "#{JSON.stringify k}:#{_compileStr v}"
		# options
		fx= ["(function(){var c= {#{cases.join ','}};"]
		# local function
		fx.push 'return function(l){'
		# get attribute to switch
		fx.push 'var sw;try{sw = l'
		for v,k in obj.s # attr to get
			if /^[a-zA-Z_][a-zA-Z0-9_]+$/i.test v
				fx.push '.', v
			else
				fx.push "[#{JSON.stringify v}]"
		fx.push ';sw=c[sw] || c.else;'
		fx.push ';}catch(err){sw=c.else}'
		# return value
		fx.push "if(typeof sw === 'function') return sw(l);"
		fx.push "else return sw;"
		# end fx
		fx.push "}"
		fx.push '})()'
		# return
		# compile
		return fx.join ''