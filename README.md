# Texturer

## Development

First, you need node. There are three dependencies that must be installed globally. Do that by running:

```npm install -g bower gulp coffee-script```

Then, to start it up, run the following from this directory:

```
bower install
npm install
gulp
```

Point a web browser at `http://localhost:8080/` and edit the HTML and SCSS in `src/`. Your changes to these files
will be deployed out to the web server on the fly.

## Baking

When you are ready to bake a texture, run `gulp compile`. This will create one image for each template in `src/html/`