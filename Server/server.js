var pnum = 8080;
var mongoose = require('mongoose');
var express =  require('express');
var app = express();

app.get('/',function(req,res){
        res.send('Blank page');
    });
app.post('',function(req,res){

    });
app.use(function(err, req, res, next) {
        console.error(err.stack);
        res.status(500).send('Error');
    });
var db = mongoose.connection;

db.on('error', function (err) {
        console.error.bind(console, 'db connection error:');
        console.log("db is disconnected")
	    process.exit();
    });
db.once('open', function () {
        console.log("db connected successfully");
    });

var server = app.listen(pnum,'0.0.0.0', function() {
        var host = server.address().address;
        var port = server.address().port;
        console.log("Listening at http://%s:%s", host, port);
    });
