$(document).ready(function() {
  var drawing_canvas = $('canvas')

  draw(drawing_canvas[0])

  $('button#clear').on('click', function(e) {
    clear()
    $.ajax({
      type: 'POST',
      url: '/remotes/' + Remote.remote_id + '/clear'
    })
  })
})

function clear() {
  var drawing_canvas = $('canvas')[0]
  drawing_canvas.width = drawing_canvas.width
}

function draw(drawing_canvas, x_coordinate, y_coordinate) {
  var context = drawing_canvas.getContext('2d')
  draw_on_canvas(drawing_canvas, context, x_coordinate, y_coordinate)
}

function remote_draw(previous_coordinates, x_coordinate, y_coordinate, color) {
  var remote_canvas = $('canvas')[0]
  var context = remote_canvas.getContext('2d')

  context.strokeStyle = color
  context.lineWidth = 5

  if (x_coordinate != null) {

    var length = previous_coordinates.length - 1
    var prev_x = parseInt(previous_coordinates[length]['x_coordinate'])
    var prev_y = parseInt(previous_coordinates[length]['y_coordinate'])

    var x = parseInt(x_coordinate)
    var y = parseInt(y_coordinate)

    context.beginPath()
    context.moveTo(prev_x, prev_y)
    context.lineTo(x, y)
    context.stroke()
  }
}

function draw_on_canvas(drawing_canvas, context, x_coordinate, y_coordinate) {
  var mousedown = false
  var color = $('input#color').val()

  $('input#color').on('change', function(e) {
    color = $('input#color').val()
  })

  drawing_canvas.onmousedown = function(e) {
    var pos = getMousePos(drawing_canvas, e)

    mousedown = true
    return false
  }

  var current_coordinates = []

  drawing_canvas.onmousemove = function(e) {
    e.preventDefault()
    var pos = getMousePos(drawing_canvas, e)

    if (mousedown) {
      current_coordinates.push({'x_coordinate': pos.x, 'y_coordinate': pos.y, 'color': color})

      if (current_coordinates.length >= 10) {
        send_coordinates(current_coordinates)

        var new_current = [current_coordinates[current_coordinates.length-1]]
        current_coordinates = new_current
      }
    }
  }

  drawing_canvas.onmouseup = function(e) {
    mousedown = false
    
    send_coordinates(current_coordinates)
    current_coordinates = []
  }
}

function send_coordinates(current_coordinates) {
  $.ajax({
    type: 'POST',
    url: '/remotes/' + Remote.remote_id + '/drawing',
    data: {'coordinates': current_coordinates}
  })
}

function getMousePos(drawing_canvas, e) {
  var rect = drawing_canvas.getBoundingClientRect()
  return {
    x: e.clientX - rect.left,
    y: e.clientY - rect.top
  }
}