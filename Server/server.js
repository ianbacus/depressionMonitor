var pnum = 8080;
var ip = '0.0.0.0';
var ip2 = '127.0.0.1';
var path = require('path');
//var DP = require('./dataProcessing');
var sensorData = require('./models/sensorData');
var mongoose = require('mongoose');
var express =  require('express');
var bodyParser = require('body-parser');
var util = require('util');
var app = express();

app.use(function(err, req, res, next) 
{
	console.error(err.stack);
	res.status(500).send('Error');
});


var db = mongoose.connection;

db.on('error', function (err) 
{
	console.error.bind(console, 'db connection error:');
	console.log("db is disconnected")
	process.exit();
});

db.once('open', function () 
{
	//var collection = db.collection('sensordatas');
	console.log("db connected successfully");
});

app.use(express.static(path.join(__dirname, 'assets')));
app.set('views', path.join(__dirname, 'assets/views'));
app.use(bodyParser.json());
app.set('view engine', 'pug');


var server = app.listen(pnum, ip, function() 
{
	var host = server.address().address;
	var port = server.address().port;
	mongoose.connect('mongodb://localhost:27017');
	console.log("Listening at http://%s:%s", host, port);
});
   
app.get('/sensorData',function(req,res)
{
	//var query = {'sensorName': req.body.sensorName};
	sensorData.find(function (err, dats)
	{
		return res.send(dats); 
	});
	
});


app.get('/',function(req,res)
{
	/*
	sensorData.find( function (err, sd) {
		return res.status(200).render('main', {title: 'view Data',sensorData:sd});
	});
	*/
	return res.status(200).render('main', {title: 'iSee Monitor'}); 
});

app.post('',function(req,res)
{
	var dataUpload = req.body;

	if(!dataUpload) return;
	dataUpload.userData = [dataUpload.userData,];
	console.log(JSON.stringify(dataUpload, null, 4));
	

	var query = {'userName': dataUpload.userName};	
	var ret = null;
	sensorData.find(query, function (err, dats) 
	{	
		if(!err)
		{
			if(0)//dats.length > 0)
			{
				console.log(JSON.stringify(dats, null, 4));
				//user exists, update/
				var datCopy = {};
				for(sensorJSON in dats)
				{
					if(sensorJSON.sensorName == dataUpload.userData[0].sensorName)
						dats.userData = sensorJSON.sensorData.append(dataUpload.userData[0].sensorData);
						break;
				}

				dats.save(function(err) {
					if (err){}
					//console.log('error')
					else{}
					//console.log('success')
				});
			}
			else
			{
				//create new user
				//console.log("Creatin guy");		
				var newData = new sensorData(dataUpload);
				newData.save(function (err) 
				{
					if (err) 
					{
						//console.log("error");
						res.status(404).send(err);
						return console.error(err);
					}
					else
					{
						//console.log("saved");
						res.status(200).send('item saved');
					}
				});
			}
		}
	});
	
});

 
 
/*

app.get('/',function(req,res)
{
	var ret;
	sensorData.find( function (err, dats) {
		return res.status(200).json(dats);
	});
	*/
	/*
	{
		console.log('wa');
		if(err)
			console.log("Error");
		else
		{
			console.log('Searching');
			collection.find(function(err, cursor)
			{
				cursor.toArray(function (err, result) {
					if (err) {
						console.log(err);
					} else if (result.length) {
						console.log('Found:', result);
						ret = result;
					} else {
						console.log('No document(s) found with defined "find" criteria!');
					}
				});
			});
		}
	});
	console.log("sending");
	res.send(ret);
	*/
	/*
	var queryResult = db.collection('sensorData').find();
	if(queryResult == null)
		res.send('Blank page');
	else
	{
		queryResult.toArray(function (err, result) {
			if (err) {
				console.log(err);
			} else if (result.length) {
				console.log('Found:', result);
				ret = result;
			} else {
				console.log('No document(s) found with defined "find" criteria!');
			}
		
		});
    }
    */
//});


