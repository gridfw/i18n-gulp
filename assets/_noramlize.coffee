###*
 * Normalize i18n object
 * @input { key: 'value1', key2:{fr: 'value', 'en': 'value'} }
 * @output { en: {key:'value1', key2: 'value'}, fr: {key: 'value1', key2: 'value'} }
###

# normalize i18n
_normalize = (data)->
	throw new Error "Normalize: Illegal input" unless typeof data is 'object' and data

	# look for all used locals
	usedLocals = []
	result = Object.create null
	for k,v of data
		if typeof v is 'object'
			throw new Error "Normalize: Illegal value at: #{k}" unless v
			# add language
			unless I18N_SYMBOL of v
				for lg of v
					unless lg in usedLocals
						usedLocals.push lg
						result[lg] = Object.create null
	throw new Error "Unless one key with all used languages mast be specified!" if usedLocals.length is 0
	# normalize
	requiredLocalMsgs = Object.create null
	for k,v of data
		# general value
		if typeof v is 'string'
			result[lg][k] = v for lg in usedLocals
		# object
		else if typeof v is 'object'
			# general value
			if I18N_SYMBOL of v
				result[lg][k] = v for lg in usedLocals
			# locals
			else
				for lg in usedLocals
					if lg of v
						result[lg][k] = v[lg]
					else
						(requiredLocalMsgs[k] ?= []).push lg
		else
			throw new Error "Normalize:: Illegal type at: #{k}"
	# throw required languages on fields
	for k in requiredLocalMsgs
		throw new Error "Required locals:\n #{JSON.stringify requiredLocalMsgs, null, "\t"}"
	# return result
	result
