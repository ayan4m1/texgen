fs = require 'fs'
gm = require 'gm'
glob = require 'glob'
gulp = require 'gulp'
path = require 'path'
sass = require 'gulp-sass'
http = require 'http-server'
watch = require 'gulp-watch'
phantom = require 'node-phantom-simple'

server = null
host = 'localhost'
port = 8080

dist = 'dist/'
src = 'src/'
html = "#{src}html/**/*.html"
scss = "#{src}scss/**/*.scss"

gulp.task 'update', ->
  console.log('updating webroot')
  [
    gulp.src(html).pipe(gulp.dest(dist))
    gulp.src(scss).pipe(sass()).pipe(gulp.dest("#{dist}css"))
  ]

gulp.task 'startServer', ->
  server = http.createServer({root: dist})
  server.listen(port)

gulp.task 'render', ['startServer'], ->
  argv = require('minimist')(process.argv)
  files = argv.files?().split(',') ? glob.sync(html) # process all files if list is not specified

  for file in files
    file = path.basename(file)
    console.log("Rendering /#{file}")
    renderPage(file)

  # server.close()

gulp.task 'default', ['update', 'render']

renderPage = (file) ->
  phantom.create (error, handle) ->
    if error?
      console.error(error)
      return

    handle.createPage (error, page) ->
      if error?
        console.error(error)
        return

      page.open "http://#{host}:#{port}/#{file}", (error, status) ->
        if error? or status isnt 'success'
          console.error(error, status)
          return

        page.renderBase64('PNG', (err, encodedImage) ->
          gm(new Buffer(encodedImage, 'base64'))
            .trim()
            .write file.replace('.html', '.png'), (err) ->
              console.error("Error writing image: #{err}") if err?
        )

        page.close
        return

      return