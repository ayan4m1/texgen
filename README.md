# Texturer

## Prerequisites

* node.js >= 0.10
* `bower`, `gulp`, and `coffee-script` installed globally
* `gm` command line utilities (http://www.graphicsmagick.org/)

## Setup

Install node and bower dependencies by running:

```
bower install
npm install
```

## Development

To start a development session, run:

```
gulp dev
```

Point a web browser at `http://localhost:8080/` and edit the HTML and SCSS in `src/`. Changes to these files will
propagate to the web server.

## Baking

When you are ready to bake your textures, run `gulp`. This will create a PNG image for each template in `src/html/`.

## Options

```
   Usage: gulp <tasks> [--port=8080] [--host=localhost]
```