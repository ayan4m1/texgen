fs = require 'fs'
gm = require 'gm'
glob = require 'glob'
gulp = require 'gulp'
path = require 'path'
P = require 'p-promise'
sass = require 'gulp-sass'
http = require 'http-server'
watch = require 'gulp-watch'
phantom = require 'node-phantom-simple'

argv = require('minimist')(process.argv)
server = null

host = argv.host ? 'localhost'
port = argv.port ? 8080

dist = 'dist/'
src = 'src/'
html = "#{src}html/**/*.html"
scss = "#{src}scss/**/*.scss"

# process all files in html source directory if list is not specified
files = argv.files?().split(',') ? glob.sync(html)

gulp.task 'update', ->
  console.log('Updating docroot')
  [
    gulp.src(html).pipe(gulp.dest(dist))
    gulp.src(scss).pipe(sass()).pipe(gulp.dest("#{dist}css"))
  ]

gulp.task 'serve', ->
  console.log("Starting http server on port #{port}")
  server = http.createServer({root: dist})
  server.listen(port)

gulp.task 'render', ->
  console.log("Rendering #{files.length} file(s)")
  P.allSettled files.map (file) -> renderFile path.basename file

# default task is to render and then exit
gulp.task 'default', ['serve', 'update', 'render'], ->
  server.close()

# dev does not exit until signalled
gulp.task 'dev', ['serve', 'update', 'render'], ->
  gulp.watch([html, scss], ['update', 'render'])

renderFile = (file) ->
  deferred = P.defer()

  phantom.create (err, handle) ->
    deferred.reject(err) if err?

    handle.createPage (err, page) ->
      deferred.reject(err) if err?

      page.open "http://#{host}:#{port}/#{file}", (err, status) ->
        deferred.reject(err ? status) if err? or status isnt 'success'

        page.renderBase64 'PNG', (err, encodedImage) ->
          deferred.reject(err) if err?

          imageFile = file.replace('.html', '.png')
          # gm does not overwrite, so clean up textures if they exist already
          fs.unlinkSync(imageFile) if fs.existsSync(imageFile)

          gm(new Buffer(encodedImage, 'base64'))
            .trim()
            .write imageFile, (err) ->
              if err?
              then deferred.reject("Error writing image: #{err}")
              else deferred.resolve()

  deferred.promise
