///////////  Configuration ///////////////

var ajaxURL            = 'http://10.23.201.2/taskmon/mon/';
var autoUpdateInterval = 10000;		// milliseconds
var ajaxTimeout        =  5000;         // milliseconds

///////   End of configuration  ///////////

var stats = {};
var intervalID;
var bVerbose = false;
var colNames = [
		"", "Service", "State","Status","TaskID", "TeamID", 
		"TeamName", "Vulnbox", "new_f_id","new_f","random_f_id","random_f"
];
var cols = [
	"state", "status", "id", "team_id", "team_name", "team_vulnbox",
	"new_f_id", "new_f", "random_f_id", "random_f"
];

function Pad2(s)
{
	return s<10 ? "0"+s : s;
}

function SetStatus(statusStr)
{
	var d = new Date();
	var prettyDate = d.getFullYear() + "." + Pad2(1+d.getMonth()) + "." + Pad2(d.getDate());
	var prettyTime = Pad2(d.getHours()) + ":" + Pad2(d.getMinutes()) + ":" + Pad2(d.getSeconds());
	var strDT = prettyDate + " - " + prettyTime + " - ";
	$("#status").html(strDT + statusStr);
}

function LoadData()
{
	SetStatus("Loading data ... ");
	var dt = new Date();
	var urlWithTime = ajaxURL + '?t=' + dt.getTime();
	$.ajax({ 
		type: "GET", 
		url: urlWithTime, 
		timeout: ajaxTimeout,
		success: OnAjaxSuccess, 
		error: OnAjaxError
	});
}

function OnAjaxError(xhr,err,ex)
{
	SetStatus("Error: " + ex);
}

function OnAjaxSuccess(data)
{
	try {
		SetStatus("Parsing JSON ... ");
		var all = jQuery.parseJSON(data);
		$("#tables").html("");
		for (var serv in all) 
			AppendServiceTable(serv, all[serv]);
		UpdateStats();
		SetStatus("Done.");
	}
	catch (e) {
		SetStatus("DataReadyCallback error: " + e);
//		alert("DataReadyCallback error: " + e);
	}
}

function AppendServiceTable(serviceName, tasksObj)
{
	stats[serviceName]={new:0, processing:0, done:0};
	SetStatus("Appending table: " + serviceName + " ... ");

	if (bVerbose) {
		var $div = $('<div>').attr('id', "div_"+serviceName);
		var $tbl = $('<table>').attr('id', "table_"+serviceName).attr('class','service');

		var colsCount = colNames.length;
		var $header = $('<tr>').attr('class','header');
		for (var i=0; i<colsCount; ++i) 
			$header.append( $('<td>').text(colNames[i]) );
		$tbl.append($header);
	} // if (bVerbose)

	var dataCount = cols.length;
	var tasksCount = tasksObj.length;
	for (var i=0; i<tasksCount; ++i) 
	{
		var t = tasksObj[i];
		stats[serviceName][t.state]++;

		if (bVerbose) {
			var $row = $('<tr>');
			$row.append( $('<td>').text(i+1) );
			$row.append( $('<td>').text(serviceName) );
			for (var j=0; j<dataCount; ++j) {
				var data = t[cols[j]];
				if (data == undefined)
					data = "-";
				var $td = $('<td>').text( data );
				if (j==0) $td.attr('class', data );	// new,processing,done
				$row.append( $td );
			}
			$tbl.append( $row );
		} // if (bVerbose)
	}
	if (bVerbose) {
		$div.append($tbl);
		$('#tables').append($div);
		$('#tables').append($('<br>'));
	} // if (bVerbose)
}

function UpdateStats()
{
	var $tbl = $('<table>').attr('id', "table_stats");
	var $header = $('<tr>');
	$header.append( $('<td>') );

	var servNames = [];
	var i=0;
	for (var serv in stats) {
		servNames[i++]=serv;
		$header.append( $('<td>').text(serv) );
	}
	$tbl.append($header);

	var $row = $('<tr>');
	$row.append( $('<td>').text("Done") );
	$row.attr('class','done');
	for (var i=0; i<servNames.length; i++)
		$row.append( $('<td>').text( stats[servNames[i]].done ) );
	$tbl.append($row);

	var $row = $('<tr>');
	$row.append( $('<td>').text("Processing") );
	$row.attr('class','processing');
	for (var i=0; i<servNames.length; i++)
		$row.append( $('<td>').text( stats[servNames[i]].processing ) );
	$tbl.append($row);

	var $row = $('<tr>');
	$row.append( $('<td>').text("New") );
	$row.attr('class','new');
	for (var i=0; i<servNames.length; i++)
		$row.append( $('<td>').text( stats[servNames[i]].new ) );
	$tbl.append($row);

	$('#summary').html($tbl);
	$('#summary').append('<br>');
}

function OnClickAutoUpdate()
{
	if ( $('#checkAutoUpdate').is(':checked') ) {
		intervalID = setInterval(LoadData, autoUpdateInterval);
	}
	else {
		clearInterval(intervalID);
	}
}

function OnClickVerbose()
{
	bVerbose = $('#checkVerbose').is(':checked');
}

function OnDocumentReady()
{
	LoadData();
	$('#buttonUpdate').click(LoadData);
	$('#checkAutoUpdate').click(OnClickAutoUpdate);
	$('#checkVerbose').click(OnClickVerbose);
	intervalID = setInterval(LoadData, autoUpdateInterval);
}

$(document).ready(OnDocumentReady);

