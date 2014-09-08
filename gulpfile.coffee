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

renders = []

# process all files in html source directory if list is not specified
files = argv.files?().split(',') ? glob.sync(html)

gulp.task 'update', ->
  console.log('updating docroot')
  [
    gulp.src(html).pipe(gulp.dest(dist))
    gulp.src(scss).pipe(sass()).pipe(gulp.dest("#{dist}css"))
  ]

gulp.task 'serve', ->
  console.log("starting http server on port #{port}")
  server = http.createServer({root: dist})
  server.listen(port)

gulp.task 'render', ['serve'], ->
  console.log("rendering #{files.length} files")
  for file in files
    renders.push renderPromise path.basename(file)

# update docroot when source changes
gulp.task 'watch', -> gulp.watch([html, scss], ['update'])

# kill http server when finished rendering
gulp.task 'stop', -> renderWait renders

# default task is to render and then exit
gulp.task 'default', ['update', 'render', 'stop']

# dev renders once and then watches for changes
gulp.task 'dev', ['update', 'render', 'watch']

renderPromise = (file) ->
  P (resolve, reject) ->
    phantom.create (err, handle) ->
      return reject(err) if err?

      handle.createPage (err, page) ->
        return reject(err) if err?

        page.open "http://#{host}:#{port}/#{file}", (err, status) ->
          return reject(err) if err? or status isnt 'success'

          page.renderBase64('PNG', (err, encodedImage) ->
            return reject(err) if err?

            gm(new Buffer(encodedImage, 'base64'))
            .trim()
            .write file.replace('.html', '.png'), (err) ->
              return reject("Error writing image: #{err}") if err?
          )

        page.close
        return resolve()

renderWait = (promises) ->
  P.allSettled(promises)
    .then(
      () ->
        console.log('renders completed')
    ,
      (err) ->
        console.log("Render failed: #{err}")
    )
    .fin ->
      server.close()