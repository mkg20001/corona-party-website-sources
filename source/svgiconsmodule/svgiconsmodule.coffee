export svgToImage = (id) ->
  # get svg
  svg = document.getElementById "svg-#{id}-icon"

  # make image
  img = new Image()

  # get svg data
  # we're loading a single symbol but with this hack :tm: it becomes an svg
  xml = new XMLSerializer().serializeToString(svg).replace('symbol', 'svg').replace('preserveAspectRatio="xMidYMid meet"', '').replace('</symbol', '</svg')

  # make it base64
  svg64 = btoa(xml)
  b64Start = 'data:image/svg+xml;base64,'

  # prepend a "header"
  image64 = b64Start + svg64;

  img.isReady = false
  img.src = image64
  img.onload = ->
    img.isReady = true

  img
