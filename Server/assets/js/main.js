

var sensorData = [];

$(function() {

	$.get('/sensorData', function (data) 
	{
		sensorData = data;
	});
	var xmin=0;
	var xmax=24;
	var sm = null;
	var plot = null;
	$( ".innie" ).click(function()
	{
		sm = $(this).attr('id');
		getData(sm);
	});
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
	
	var xoffset = 12;
	var xscale = 1;
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
	function getData(sensorSetting)
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
					if(sensor.sensorName == sensorSetting)
					{
						//$.each(value.sensorData, function(key,value) 
						for(valueIX in sensor.sensorData)
						{
							value = sensor.sensorData[valueIX]
							var start_pos = value.date.indexOf('(') + 1;
							var end_pos = value.date.indexOf(')',start_pos);
							var date = value.date.substring(start_pos,end_pos-3);
							date = date.replace(/:/g, ".")
							var data = processData(value.data,sensorSetting);
							//console.log(ret);
							ret.push([date,data]);
						}
					}
				}
			}
			plot = $.plot("#placeholder", [ret], {
				 series: {
					shadowSize: 0
				 },
				 yaxis: {
					min: 0, max: 10
				 },
				 xaxis: {
					min : xmin, max : xmax
				 },
				 colors: ["#FF7070",]
			 });
		});
		
//		return [[1,1],[2,2],[3,3],[4,4],[5,5],[6,6] ];
		//res.push([window_index,element]);
	}
	
	 
	 function drawPlot()
	 {
	 	plot.setData([getData()]);
		plot.setupGrid();
		plot.draw();
	 }
});