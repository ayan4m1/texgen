gulp = require 'gulp'

sass = require 'gulp-sass'
watch = require 'gulp-watch'

http = require 'http-server'
phantom = require 'node-phantom-simple'

startServer = ->
  http.createServer(
    root: 'dist/'
  ).listen 8080

renderPage = ->
  phantom.create (error, handle) ->
    if error?
      console.log(error)
      return

    handle.createPage (error, page) ->
      if error?
        console.log(error)
        return

      page.viewportSize = {
        height: 1
        width: 1
      }

      page.open "http://localhost:8080/example.html", (error, status) ->
        if error? or status isnt 'success'
          console.log(error, status)
          return

        page.render 'test.png'

        page.close
        return

      return

scssSource = gulp.src('src/main/scss/**/*.scss')
htmlSource = gulp.src('src/main/html/**/*.html')

scssCompile = (files) -> files.pipe(sass()).pipe(gulp.dest('dist/css'))
htmlCompile = (files) -> files.pipe(gulp.dest('dist'))

updateDist = (useWatch) ->
  if useWatch
    scssSource = scssSource.pipe(watch())
    htmlSource = htmlSource.pipe(watch())

  scssSource.pipe(sass()).pipe(gulp.dest('dist/css'))
  htmlSource.pipe(gulp.dest('dist'))
  return

gulp.task 'default', ->
  startServer()
  updateDist(true)

gulp.task 'compile', ->
  updateDist(false)
  startServer()
  renderPage()