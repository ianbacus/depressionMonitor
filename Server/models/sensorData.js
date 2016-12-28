var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var DataSchema = new Schema({
	userName            : {type: String, required: true}
	data                : {type: String, required: true}
    });

var userData = mongoose.model('userData', DataSchema);
module.exports = userData;

