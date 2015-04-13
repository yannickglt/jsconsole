gulp = require 'gulp'
#gcson = require 'gulp-cson'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
sass = require 'gulp-sass'
refresh = require 'gulp-livereload'

connect = require 'connect'
http = require 'http'
path = require 'path'
lr = require 'tiny-lr'
server = do lr

files = [ 'src/app/prettify.packed.js', 'src/app/EventSource.js', 'src/app/console.js' ]

#gulp.task 'cson', ->
#  gulp.src './config.cson'
#    .pipe gcson()
#    .pipe gulp.dest './'

# Starts the webserver (http://localhost:8080)
gulp.task 'connect', ->
	port = 8080
	hostname = null # allow to connect from anywhere
	base = path.resolve 'build'
	directory = path.resolve 'build'

	app = connect()
		.use(connect.static base)
		.use(connect.directory directory)

	http.createServer(app).listen port, hostname

# Starts the livereload server
gulp.task 'livereload', ->
	server.listen 35729, (err) ->
		console.log err if err?

# Compiles CoffeeScript files into js file
# and reloads the page
gulp.task 'build', ->
	gulp.src('src/app/**/*.coffee')
		.pipe(concat 'console.coffee')
		.pipe(do coffee)
		.pipe(do uglify)
		.pipe(gulp.dest './build')
		.pipe(refresh server)

	gulp.src(files)
		.pipe(concat 'console.js')
		.pipe(do uglify)
		.pipe(gulp.dest './build')
		.pipe(refresh server)

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'sass', ->
	gulp.src('src/scss/console.scss')
#		.pipe(sass includePaths: ['scss/includes'])
		.pipe(concat 'console.css')
		.pipe(gulp.dest './build')
		.pipe(refresh server)

# Reloads the page
gulp.task 'html', ->
	gulp.src('src/**/*.html')
		.pipe(gulp.dest './build')
		.pipe(refresh server)

# The default task
gulp.task 'default', ->
	gulp.run 'connect', 'livereload', 'build', 'sass', 'html'

	# Watches files for changes
	gulp.watch ['src/app/**/*.coffee', files], ->
		gulp.run 'build'

	gulp.watch 'src/scss/**/*.scss', ->
		gulp.run 'sass'

	gulp.watch 'src/**/*.html', ->
		gulp.run 'html'
