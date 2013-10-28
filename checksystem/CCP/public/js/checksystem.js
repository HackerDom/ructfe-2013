var autoupdate;
var autoDelay = 2000;

$(document).ready(function() {

	var $teams = $("#team");
	if ($teams.length) {
		$.getJSON("/ajax/teams", function(j){
			$teams.empty();
			$teams.append($('<option />').val('').text('[ All teams ]'));
			$.each(j, function(key, val) { $teams.append($('<option />').val(key).text(key+' - '+val)); });
        	});
	}

	var $services = $("#service");
	if ($services.length) {
		$.getJSON("/ajax/services", function(j){
			$services.empty();
			$services.append($('<option />').val('').text('[ All services ]'));
			$.each(j, function(key, val) { $services.append($('<option />').val(key).text(key+' - '+val)); });
        	});
	}

	var $logcount = $("#logcount");
	if ($logcount.length) {
		$logcount.empty();
		var c=[10,50,100,500,1000];
		for (var i=0; i<c.length; i++) {
			$logcount.append($('<option />').val(c[i]).text('Last '+c[i]));
		}
		$logcount.append($('<option />').val(-1).text('All items'));
	}

	var $btnViewLog = $("#btnViewLog");
	if ($btnViewLog.length) {
		$btnViewLog.bind("click", logtableUpdate);
	}

	var $autoupdate = $("#autoupdate");
	if ($autoupdate.length) {
		$autoupdate.click(autoupdate_Click);
	}

	fillServiceTable();
	fillTeamTable();
});

function btnGitPull_Click() {
	$("#gutPullInfo").html("Working ... ");
	$("#btnGitPull").attr("disabled", "disabled");
	$.get('/ajax/gitpull', gitPullSuccess).error(gitPullError);
}

function autoupdate_Click() {
	if ($("#autoupdate").is(':checked')) {
		autoupdate = setTimeout(logtableUpdate, autoDelay);
		$("#btnViewLog").attr("disabled", "disabled");
	}
	else {
		clearTimeout(autoupdate);
		$("#btnViewLog").removeAttr("disabled");
	}
}

function gitPullSuccess(data) {
	$("#gutPullInfo").html(data);
	$("#btnGitPull").removeAttr("disabled");
}

function gitPullError(xhr) {
	$("#gutPullInfo").html("ERROR: " + xhr.status + " - " + xhr.statusText + "\n" + xhr.responseText);
	$("#btnGitPull").removeAttr("disabled");
}

function logtableUpdate() {
	$.post(
		'/ajax/log', 
		{
			team:     $('#team').val(),
			service:  $('#service').val(),
			logcount: $('#logcount').val(),
			result:   $('#result').val()
		},
		ajaxLogSuccess
	);
}

function fillServiceTable() {
        $.get('/ajax/services/detail', ajaxServSuccess);
}

function fillTeamTable() {
	$.get('/ajax/teams/detail', ajaxTeamSuccess);
}

function ajaxTeamSuccess(data) {
	$('#teamtable tr').not(':first').remove();
	$('#teamtable tr').first().after(data);
}

function ajaxServSuccess(data) {
	$('#servtable tr').not(':first').remove();
	$('#servtable tr').first().after(data);
}

function ajaxLogSuccess(data) {
	$('#logtable tr').not(':first').remove();
	$('#logtable tr').first().after(data);

	if ($("#autoupdate").is(':checked')) {
		autoupdate = setTimeout(logtableUpdate, autoDelay);
	}
}

function ajaxError(jqXHR,textStatus,errorThrown) {
	var msg = "Ajax error\n";
	msg += "textStatus = '" + textStatus + "'\n";
	msg += "errorThrown = '" + errorThrown + "'\n";
	alert(msg);
}

function btnShowHideService_Click() {
	var div = $('div#formaddservice');
	var btn = $('#show_hide_service');
	div.toggleClass('invisible');
	btn.prop('value', div.hasClass('invisible') ? '>>' : '<<');
}

function btnAddService_Click() {
	$.post(
		'/ajax/services/add', {
			id:       $('#id').val(),
			name:     $('#name').val(),
			checker:  $('#checker').val(),
		},
		btnAddService_OK
	);
}

function btnAddService_OK() {
	alert('Service added');
	$('#id').val('');
	$('#name').val('');
	$('#checker').val('');
	$('#show_hide_service').trigger('click');
	fillServiceTable();	
}

