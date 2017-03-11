

var sensorData = [];
//One full days worth of data will be stored in each of these arrays. The functions below 
// are meant to be used on subsets of that data for visualization
var unpackedSensorData = {
	'screenData':[], 	//[T,bool]
	'lightData':[],
	'motionData':[], 	//[T, enum]
	'gpsData':[]		//[T,lat,long]
}
var currentMonth = new Date().getMonth();
var floptions = 
{
	'defaultOptions':
	{
		ticks: function(axis){
		   return axis.max < 28 ? [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31] : axis.tickGenerator(axis);
		},
		series: {
			shadowSize: 0
		},
		yaxis: {
			min: 0, max: 10
		},
		xaxis: {
			mode: "time",  timeformat: "%m/%d/%y",   maxTickSize: [1, "day"],
			min : new Date(2017, 0, 1), max : new Date(2017, 0, 30)
		},
		colors: ["#FF7070",]
	},
	'activityOptions':
	{
		xaxis: {
			minTickSize: 1
		},
		series: {
			bars: {
				show: true,
				barWidth: .9,
				align: "center"
			},
			stack: true
		}
	}						 
}

$(function() {

	
	function binData()
	{
		$.each(sensorData, function() {
			var ret = [];
			//$.each( sensorData, function( key, value ) {
			for(dataIX in sensorData)
			{
				var userData = sensorData[dataIX].userData;
				//$.each(value.userData, function (key, value) 
				for(userIx in userData)
				{
					
					var sensor = userData[userIx];
					
						//$.each(value.sensorData, function(key,value) 
					for(valueIX in sensor.sensorData)
						{
						value = sensor.sensorData[valueIX]
						var start_pos = value.date.indexOf('(') + 1;
						var end_pos = value.date.indexOf(')',start_pos);
						var date = value.date.substring(start_pos,end_pos-3);
						date = date.replace(/:/g, ".")
						var data = processData(value.data,sensorSetting);
						
						if(sensor.sensorName == 'AmbientLight')
						{
							unpackedsensorData['lightData'].push([date,data]);
						}
						if(sensor.sensorName == 'Location')
						{
							unpackedsensorData['gpsData'].push([date,data]);
						}
						if(sensor.sensorName == 'Activity')
						{
							unpackedsensorData['activityData'].push([date,data]);
						}
					}
				}
			}
		});
	}
	/*
	$.get('/sensorData', function (data) 
	{
		sensorData = data;
	});*/
	//generateSensorData();
	//unpackedSensorData = getGeneratedSensorData();
	
	
	var xmin=0;
	var xmax=24;
	var sm = null;
	
	
	 
	
	 /*
	  *	Take a dataset of timestamped data, regroup it with an array of each months' data
	  */
	 function groupDataByMonth(dataSet)
	 {
	 	//Get the date of the initial datapoint
	 	var timestamp = dataSet[0][0];
	 	var date = new Date(timestamp*1000);
	 	var currentMonth = date.getMonth();
	 	var groupedSet = [[],[],[],[],[],[],[],[],[],[],[],[],]
	 	var monthEntry = []
	 	for(i in dataSet)
	 	{
	 		timestamp = dataSet[i][0];
	 		var month = new Date(timestamp*1000).getMonth();
	 		if(month != currentMonth)
	 		{
	 			groupedSet[currentMonth] = monthEntry;
	 			monthEntry = [];
	 			currentMonth = month;
	 		}
	 		
		 	monthEntry.push(dataSet[i]);
	 	}
	 	groupedSet[currentMonth] = monthEntry;
	 	return groupedSet;
	 }
	 
	 /*
	  *	Take a dataset of timestamped data, regroup it with an array of each days' data
	  */
	 function groupDataByDay(dataSet)
	 {
	 	//Get the year of the initial datapoint
	 	var timestamp = dataSet[0][0];
	 	var date = new Date(timestamp*1000);
	 	var currentDay = date.getDay();
	 	var groupedSet = []
	 	var dayEntry = []
	 	
	 	for(i in dataSet)
	 	{
	 		timestamp = dataSet[i][0];
	 		var day = new Date(timestamp*1000).getDay();
	 		if(day != currentDay)
	 		{
	 			groupedSet.push(dayEntry);
	 			dayEntry = [];
	 			currentDay = day;
	 		}
	 		
		 	dayEntry.push(dataSet[i]);
	 	}
	 	groupedSet.push(dayEntry);
	 	return groupedSet;
	 }
	 
	 /*
	 *	Generate series 
	 */
	 {
		 //Sleep related: duration, bedtime vs day
	 	function generateSleepSet()
		{
			console.log('GENSLEEP',currentMonth,unpackedSensorData.screenData[currentMonth]);
			var dailyData =
			{
				'screen':groupDataByDay(unpackedSensorData.screenData[currentMonth]),
				'light':groupDataByDay(unpackedSensorData.lightData[currentMonth]),
				'motion':groupDataByDay(unpackedSensorData.motionData[currentMonth])
			}
				
			console.log(dailyData.screen[0]);
			analyzeSleep(dailyData.screen,dailyData.light,dailyData.motion)
			
		}
	 
		 //Location: time from home, 
		 function generateGpsSet()
		 {
		 
		 }
		 
		 //Activity: stationary time/active time per day
		 function generateActivitySet()
		 {
			var series = [{
				data: [],
				label: "Stationary time"
			},
			{
				data: [],
				label: "Active time"
			}];
			var dailySensorData = groupDataByDay(unpackedSensorData['activity'])
			for(dayIx in dailySensorData)
			{
				var daysData = dailySensorData(dayIx);
				var analyzed = analyzeActivity(daysData);
				series[0].push(dayIx,analyzed.totalTimeStationary);
				series[1].push(dayIx,analyzed.totalTimeActive);
			}
			return series;
		 }
	 
	 
		 
		 //Phone screen: 
		 function generateScreenSet()
		 {
		
		 }
	 }
	 /*	Plotting
		 */
	{
		function xyzqwerty()
		{
			$.plot("#placeholder", [0,0], {
				xaxis: { mode: "time" }
			});
		 }
		 
		 function drawPlot(plot)
		 {
		 	console.log(plot);
			plot.setupGrid();
			plot.draw();
		 }
	 
		function plotForMode(plotMode)
		{
		 	var plot;
			switch(plotMode)
			{
				case 0:
					var series = generateSleepSet();
					plot = $.plot("#placeholder", series, {});
					break;
				case 1:
					var series = generateActivitySet();
					plot = $.plot("#placeholder", series, floptions.activitiyOptions);
					break;
				case 2:
					var series = generateScreenSet();
					plot = $.plot("#placeholder", series, {});
					break;
				case 3:
					var series = generateGpsSet();
					plot = $.plot("#placeholder", series, {});
					break;
				case 4:
					plot = $.plot("#placeholder", [0,0], floptions.defaultOptions);
					break;
				default:
					break;
			}
			
			drawPlot(plot);
		}
		plotForMode(4);
	 }
	 
	 /*
	 *	UI Elements
	 */
	 {
	 	$( ".procPick" ).click(function()
		{
			$('.procPick').removeClass('ui-state-active').css({'color':'black'});
			$(this).addClass('ui-state-active').css({'color':'white'});
			
			
			var btnId = $(this).attr('id');
			if(btnId == 'getSleep')
				plotForMode(0);
			else if(btnId == 'getActivity')
				plotForMode(1);
			else if(btnId == 'getScreen' )
				plotForMode(2);
			else if(btnId == 'getGPS' )
				plotForMode(3);
			else if(btnId == 'getD')
			{
				unpackedSensorData = getGeneratedSensorData();
				for (var setKey in unpackedSensorData) {
					if (unpackedSensorData.hasOwnProperty(setKey)) 
					{
						//console.log(key + " -> " + p[key]);
						unpackedSensorData[setKey] = groupDataByMonth(unpackedSensorData[setKey]);
					}
					console.log("Month data",unpackedSensorData);
				}
			}
		});
		$("#InlineMenu").MonthPicker({
			SelectedMonth: '04/' + new Date().getFullYear(),
			OnAfterChooseMonth: function(selectedDate) {
			// Do something with selected JavaScript date.
            // console.log(selectedDate);
            	currentMonth = selectedDate.getMonth();
        }
    });
    
	
	
	
	 
	 }
});



/*
function getData(sensorSetting)
	{
			plot = $.plot("#placeholder", {
				 series: {
					shadowSize: 0
				 },
				 yaxis: {
					min: 0, max: 10
				 },
				 xaxis: {
				 	mode: "time",  timeformat: "%m/%d/%y",   minTickSize: [1, "day"],
					min : xmin, max : xmax
				 },
				 colors: ["#FF7070",]
			 });
		
		
//		return [[1,1],[2,2],[3,3],[4,4],[5,5],[6,6] ];
		//res.push([window_index,element]);
	}
	
*/

/*
$( "#submit" ).click(function()
	{
		if(plot != null)
		{
			console.log(ret);
			xmin = parseFloat($("#Lower:text").val());
			xmax = parseFloat($("#Upper:text").val());
			console.log(xmin,xmax);
			//plot.getAxes().xaxis.options.min = xmin;
			//plot.getAxes().xaxis.options.max = xmax;
			getData(sm);
		}
	});
*/
/*
	$(".slider" ).slider({
		value: 12,
		min: 0,
		max: 24,
		step: 1})
	.on({
		slide: function( event, ui ) 
		{
			var slideval = $(this).slider("option", "value");
			var id = $(this).attr("id");
			switch(id) {
				case 'xs':
					//percentage of 24 hour period to show
					xscale = ((slideval-12)/24);
					break;
				case 'xo':
					//number of hours to offset
					xoffset = slideval;
					break;
			}
			plot.getAxes().xaxis.options.min = xoffset;
			plot.getAxes().xaxis.options.max = xoffset + 24*xscale;
		}
	});
	*/
	/*
	function processData(str,setting)
	{
		//normalize all data to a scale from 0 to 5
		if(setting == "Activity")
		{
			if ( str.includes("Stationary") ) return 1;
			if ( str.includes("Walking") ) return 2;
			if ( str.includes("Run") ) return 3;
			if ( str.includes("cycl") ) return 4;
			if ( str.includes("riv") ) return 5;
		}
		else if(setting == "Screen")
		{
			if ( str.includes("On") ) return 1;
			if ( str.includes("Off") ) return 0;
		}
		else if(setting == "Social")
		{
		}
		else if(setting == "AmbientNoise")
		{
			if( str.includes("Silent"))
			{
				console.log("SILENCE");
				return 1;
			}
			else if(str.length < 150) {
				console.log("(" + str + ")");
				//var obj = JSON.stringify(eval("{" + str + "}"));
				
				var ret = parseFloat(stringToSplit.split(',')[2]);
				return ret/100;
			}
			else return 0;
		}
		else if(setting == "AmbientLight")
		{
			return parseFloat(str)*5;
		}
		
		
	}
*/

