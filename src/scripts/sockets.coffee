window.socket = io('http://localhost:3000')

socket.on 'ports', (data) ->
  console.log(data)

socket.on 'status', (data) ->
  console.log(data)
  if data.ready
    console.log 'Ready to transmit'
    # animate(0)

socket.on 'serial', (data) ->
  $('.serial').empty()
  data.ports.forEach (port) ->
    console.log port.comName
    if port.comName.search('Bluetooth') < 0
      $('.serial')
        .append(
          $('<button>',{class:'port'})
            .html port.comName
            .click (() ->
              $(this).addClass('selected')
              console.log { port: $(this).html(), baud:9600}
              socket.emit('serial', { port: $(this).html(), baud:9600})
            )
        )

threshold = 500
socket.on 'readings', (data) ->
  console.log data.d
  if data.d[0] < threshold*2
    if data.d[1] > threshold and data.d[1] > data.d[2]
      answer('no')
    else if data.d[2] > threshold and data.d[2] > data.d[1]
      answer('yes')

@answer = (ans) ->
  clearTimeout(window.resetCard)
  $('.question')
    .removeClass('yes')
    .removeClass('no')
    .addClass(ans)
  window.resetCard = setTimeout(answer,1000)