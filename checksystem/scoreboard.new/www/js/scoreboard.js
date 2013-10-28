var services = [];
var teams = [];
var dataUrl = "";
var teamsLoaded = 0;
var servicesLoaded = 0;
var cfg;

var int_UpdateData;	// Interval ID
var int_UpdateConfig;	// Interval ID

$(document).ready(Scoreboard_Init);

function Scoreboard_Init() {
	$('body').on('click', 'button[url]', GroupChange_Click);
	$('body').on('click', 'button#Update', Update_Click);

	$.ajaxSetup({ cache: false });	// Is it good ?
	$.getJSON("data/services.json", Load_Services);

	Update_Config();
	int_UpdateConfig = setInterval(Update_Config, 60000);
}

function Update_Config() {
	$.getJSON("data/config.json", Load_Config);
}

function Update_Data() {
	if (teamsLoaded && servicesLoaded && dataUrl.length) {
		$('#statusText').text('Updating ...');
	        $.getJSON(dataUrl+"score.json", Load_Score);
		$.getJSON(dataUrl+"status.json", Load_Status);
		$.getJSON(dataUrl+"ping.json", Load_Ping);
		$('div#info').load(dataUrl+"info.txt");
	}
}

function GroupChange_Click() {
	dataUrl = $(this).attr('url');
	$("#selectedGroup").text($(this).text());
	$.getJSON(dataUrl+"teams.json", Load_Teams);
}

function Load_Config(c) {
	cfg = c;
	$("#teamGroups").find("button").remove();	// Delete all buttons
	$.each(c.groups, function(name,url) {
		$("#teamGroups").append(
			$('<button>').text(name).attr('url', url)
		);
	});
	if (dataUrl.length==0) {
		$("#teamGroups > button:first").click();	// Open first group
	}
	clearInterval(int_UpdateData);
	int_UpdateData = setInterval(Update_Data, c.updateDataInterval*1000);
}

function Update_Click() {
	Update_Data();
}

function Update_Status() {
	$('#statusText').text("Updating status ... ");
	$.getJSON(dataUrl+"status.json", Load_Status);
}

function Load_Services(s) {
	services = s;
	var tr = $(".scoreboard tbody tr:first");
	$.each(s, function(key,val){
		tr.append( $("<th>").text(val) );
	});
	servicesLoaded = 1;
}

function Load_Teams(t) {
	$(".scoreboard").find("tr:gt(0)").remove();	// Delete all teams
	teams = t;
	$.each(t, function(id,name) {
		var tr = $('<tr>').append(
					$('<td>').text(id),
					$('<td>').append($('<img>').attr('src', 'img/'+name+'.png')),
					$('<td>').text(name),
					$('<td>').text('0').attr('class','score rat'),
					$('<td>').text('0').attr('class','score def'),
					$('<td>').text('0').attr('class','score att'),
					$('<td>').text('0').attr('class','score adv'),
					$('<td>').text('?').attr('class','ping')
				);
		tr.attr('class', 'team_'+id);
		$.each(services, function(sid,sname) {
			tr.append($('<td>').attr('class','status service_' + sid));
		});
		$(".scoreboard").find('tbody').append(tr);
	});
	teamsLoaded = 1;
	Update_Data();		// Auto update data when teams loaded.
}

function Update_TimeText() {
	$('#statusText').text("Updates every " + cfg.updateDataInterval + " sec. Last update: " +  Date());
}

function Load_Score(sc) {
	for (var i=0; i<sc.length; i++) {
		var tr = $('tr.team_'+sc[i].team);
		if (tr.length) {
			tr.find('td.rat').text(sc[i].rat);
			tr.find('td.def').text(sc[i].def);
			tr.find('td.att').text(sc[i].att);
			tr.find('td.adv').text(sc[i].adv);
		}
	}
	Update_TimeText();
}

function Load_Ping(pi) {
	$.each(pi, function(tid,obj) {
		var td = $('tr.team_'+tid).find('td.ping');
		if (td.length) {
			var txt = obj.r+'/'+obj.t+'/'+obj.v;
			td.text(txt.replace(/0/g,'-').replace(/1/g,'+'));
		}
	});
}

function Load_Status(st) {
	$.each(st, function(tid,obj) {
		var tr = $('tr.team_'+tid);
		if (tr.length) {
			$.each(obj, function(sid,stat) {
				var td = tr.find('td.service_'+sid);
				if (td.length) {
					td.text(stat);
					td.attr('class', 'status service_' + sid + ' ' + stat);
				}
			});
		}
	});
	Update_TimeText();
}

