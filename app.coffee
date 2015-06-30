# App --------------

express = require 'express'
app = express()
server = require('http').Server(app)
io = require('socket.io')(server)

# Imports ----------

path = require('path')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')

# Routing ----------

routes = require('./routes/index')
app.use('/',routes)

# Views ------------

app.set('views',path.join(__dirname,'views'))
app.set('view engine','jade')

# Middleware ------

app.use(cookieParser())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: false}))

app.use(require('stylus').middleware(
  src:  path.join(__dirname, '/src/')
  dest: path.join(__dirname, '/public/')
))

app.use(express.static(path.join(__dirname, 'public')))

# Serving ----------

# app.set('port',process.env.PORT or 3000)
app.set('port',3000)

server = server.listen app.get('port'), () ->
  host = server.address().address
  port = server.address().port

  console.log 'App listening at http://%s:%s', host, port

serial = require("serialport")

io.on 'connection', (socket) ->
  console.log '--- Socket Connected'

  serial.list (err, ports) ->
    socket.emit('serial', { ports: ports })
    socket.on 'serial', (data) ->
      console.log data
      SerialPort = serial.SerialPort
      serialPort = new SerialPort data.port,
        baudrate: data.baud

      serialPort.on "open", () ->
        console.log('--- Port is open')

        socket.emit('status', { ready: true });

        serialPort.on 'data', (data) ->
          # console.log('D_IN: ' + data)
          data = data.toString().split(',')
          data = (parseFloat str for str in data)
          socket.emit('readings', { d: data });
