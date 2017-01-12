var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var DataSchema = new Schema(
{
	userName            : {type: String, required: true},
	userData			: 
	[{
		sensorName      : {type: String, required: true},
		sensorData		:
		[{
			date        : {type: String, required: true},		
			data        : {type: String, required: true}
		}]
	}]
});

var sensorData = mongoose.model('sensorData', DataSchema);
module.exports = sensorData;

