

//One full days worth of data will be stored in each of these arrays. The functions below 
// are meant to be used on subsets of that data for visualization
var sensorData = {
	'screen':[], 	//[T,bool]
	'activity':[], 	//[T, enum]
	'gps':[],		//[T,lat,long]
}



/*
 *	Extract raw data for a sensor: 
 */
function unPackDataSeries()
{
	
}

/*
 *	Pass in a dataset of {T, d1, d2...dn} datapoints, and a dataIndex [1],[2],...[n] for accessing
 *	 some element dn for each datapoint
 */
 function getRawData(dataSet,dataIndex)
 {
 	var ret= [];
 	for(i in dataSet) ret.push(dataSet[i][dataIndex];
 	return ret;
 }
 
/*
 *	Statistical analysis methods
 */
var arr = {	
	max: function(array) {
		return Math.max.apply(null, array);
	},
	
	min: function(array) {
		return Math.min.apply(null, array);
	},
	
	range: function(array) {
		return arr.max(array) - arr.min(array);
	},
	
	midrange: function(array) {
		return arr.range(array) / 2;
	},

	sum: function(array) {
		var num = 0;
		for (var i = 0, l = array.length; i < l; i++) num += array[i];
		return num;
	},
	
	mean: function(array) {
		return arr.sum(array) / array.length;
	},
	
	median: function(array) {
		array.sort(function(a, b) {
			return a - b;
		});
		var mid = array.length / 2;
		return mid % 1 ? array[mid - 0.5] : (array[mid - 1] + array[mid]) / 2;
	},
	
	modes: function(array) {
		if (!array.length) return [];
		var modeMap = {},
			maxCount = 0,
			modes = [];

		array.forEach(function(val) {
			if (!modeMap[val]) modeMap[val] = 1;
			else modeMap[val]++;

			if (modeMap[val] > maxCount) {
				modes = [val];
				maxCount = modeMap[val];
			}
			else if (modeMap[val] === maxCount) {
				modes.push(val);
				maxCount = modeMap[val];
			}
		});
		return modes;
	},
	
	variance: function(array) {
		var mean = arr.mean(array);
		return arr.mean(array.map(function(num) {
			return Math.pow(num - mean, 2);
		}));
	},
	
	standardDeviation: function(array) {
		return Math.sqrt(arr.variance(array));
	},
	
	meanAbsoluteDeviation: function(array) {
		var mean = arr.mean(array);
		return arr.mean(array.map(function(num) {
			return Math.abs(num - mean);
		}));
	},
	
	zScores: function(array) {
		var mean = arr.mean(array);
		var standardDeviation = arr.standardDeviation(array);
		return array.map(function(num) {
			return (num - mean) / standardDeviation;
		});
	}
};


/*
 *	Determine when user goes to sleep. Get GPS location of this place
 */
function findUsersHome(gpsData,screenData,lightData,motionData)
{
	var bedTime = analyzeSleep(screenData,lightData,motionData);
	var location = null;
	for(i in gpsData)
	{
		var dataPoint = gpsData[i];
		var timestamp = dataPoint[0];
		
		if(timeStamp >= bedTime)
		{
			location = [dataPoint[1],dataPoint[2]];
			break;
		}
	}
	return location;
}

/*
 *	Use light, screen, and motion data to detect sleep time
 */
function analyzeSleep(screenData,lightData,motionData)
{
	
	//Get last screen turn off for the night
	
	//Last recorded time phone screen turns off
	var lastScreenCheckTimestamp;
	
	for(i in screenData)
	{
		var dataPoint = screenData[i];
		var timestamp = dataPoint[0];
		var event = dataPoint[1];
		
		if(event == 0) lastScreenCheckTimestamp = timestamp;
		
	}
	
	//Find point when light drops below and stays below a threshold
	
	var lightsOffTimeStamp = 0;
	//If light variance doesn't change, auto-brightness is off
	var lightVariance = arr.variance(getRawData(lightData));
	if(lightVariance != 0)
	{
		//Iterate backwards: find when light goes above a threshold
		for(var i=lightData.length-1;i >=0;--i)
		{
			var dataPoint = lightData[i];
			var timestamp = dataPoint[0];
			var ambientLight = dataPoint[1];
		
		
			//Dark room: auto-brightness will be below .4
			if(ambientLight < 0.4)
			{
				lightsOffTimeStamp = timestamp;
				break;
			}
		
		}
	}	
	//Find long stable low value of motion
	for(var i=motionData.length-1;i >=0;--i)
	{
		var dataPoint = motionData[i];
		var timestamp = dataPoint[0];
		var event = dataPoint[1];
		
		//Stationary object will always have motion value 1, the earliest time with a motion
		//value greater than 1 will indicate the last movement
		if(event < 2)
		{
			motionStopTimestamp = timestamp;
			break;
		}	
	}
	
	//return timestamp of sleep time
	return Math.min(lastScreenCheckTimestamp, lightsOffTimeStamp, motionStopTimestamp);
	
	
}

/*
 *	Use screen on/off events to analyze phone screen viewing time 
 */
function analyzePhoneUse(screenData)
{
	ret = {
		'totalUse':[],//cumulative distribution
		'phoneChecks':[], //cumulative distribution
		'frequencyChecks':null,
		'dataSeries':[]
	}
	
	//current sum of time spent viewing phone
	var totalUse = 0;
	
	//current sum of times phone is opened
	var phoneChecks = 0;
	
	//temporary variable for phone timestamp+duration data series
	var tempOnTime = null;
	
	for(i in screenData)
	{
		var dataPoint = screenData[i];
		var timestamp = dataPoint[0];
		var event = dataPoint[1];
		if(event == 1)
		{
			phoneChecks += 1;
			ret.phoneChecks.push([timestamp,phoneChecks])
			if(tempOnTime != null)
			{
				var onDuration = timestamp - tempOnTime;
				//push timestamp+duration of phone view
				ret.dataSeries.push([tempOnTime,onTime])
				
				//add to total use time
				totalUse += onTime;
				ret.totalUse.push(timestamp,totalUse);
				
			}
			//update temp variable
			tempOnTime = timestamp;		

		}
	}
	
}

/*
 *	
 */
function analyzeActivity()
{
	var ret = {
		'totalTimeStationary':[],
		'totalTimeActive':[],
		'dataSeries':[],
	}
	var tempOnTime = null;
	var lastMotionEvent = 0;
	for(var i=motionData.length-1;i >=0;--i)
	{
		var dataPoint = motionData[i];
		var timestamp = dataPoint[0];
		var event = dataPoint[1];
		if(tempOnTime != null) 
		{
			eventDuration = timestamp - tempOnTime;
			switch(lastMotionEvent)
			{
				case 5://driving
				case 1://stationary
					ret.totalTimeStationary.push[timestamp,eventDuration];
					break;
				case 2://walking
				case 3://running
				case 4://biking
					ret.totalTimeActive.push[timestamp,eventDuration];
					break;
			}
		}
		lastMotionEvent = event;
		tempOnTime = timestamp;
		
		
		
	}
}

/*
 *	Analyze gps Data
 */
function analyzeLocations(gpsData,screenData,lightData,motionData)
{
	ret = {
		'timeFromHome':[], //cumulative distribution
		'timeAtOneLocation':[], 
	}
	var userHome = findUsersHome(gpsData, screenData, lightData, motionData);
}
