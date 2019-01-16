const gulp = require('gulp');
const gutil = require('gulp-util');
const coffeescript	= require('gulp-coffeescript');
const Gi18nCompiler = require('..');


// Compile locals
function compileLocals(){
	return gulp.src('assets/**/*.coffee')
		.pipe( coffeescript({bare: true}) )

		// compile into JSON files
		// .pipe( Gi18nCompiler() )

		// compile into JS files: precompile pug
		.pipe( Gi18nCompiler({ compilePug: true }) )

		.pipe( gulp.dest('build') )
		.on('error', gutil.log)
}

function watch(){
	gulp.watch('assets/**/*.coffee', compileLocals);
}

gulp.task('default', gulp.series(compileLocals, watch));