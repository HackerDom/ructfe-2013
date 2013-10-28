var h;

$(function() {
    fetchData();
});

function fetchData() {
    $.ajax({
        url: "scores.json",
        method: 'GET',
        dataType: 'json',
        success: onDataReceived,
        error: onFailDataReceive
    });
}

function onDataReceived(series, textStatus, XMLHttpRequest) {
    h = series;
    if (h.round_times.length > 0) {
        var startTime = h.round_times[0] - 1.5 * 60 * 60 * 1000;
        for (var i = 0; i < h.round_times.length; i++)
            h.round_times[i] -= startTime;
    }

    for (var team_N in h.teams) {
        var team = h.teams[team_N];
        team.total = [];
        for (var j = 0; j < team.defense.length; j++) {
            team.total.push(team.defense[j] + team.attack[j] + team.advisories[j] + team.tasks[j]);
        }
    }

    populateTeamsList(getTeamsFromHistory());
    plot();
}

function onFailDataReceive(XMLHttpRequest, textStatus, errorThrown) {
    setTimeout("fetchData()", 5000)
}

function getTeamsFromHistory() {
    var teams = [];
    for (var key in h.teams)
        teams.push(h.teams[key].name);
    return teams;
}

function populateTeamsList(teams) {
    var choiceContainer = $("#teams_list");
    $.each(teams, function(idx, val) {
        choiceContainer.append('<br/><input type="checkbox" name="' + val + '" id="' + val + '" class="teamCheckbox"><label>' + val + '</label>');
    });
    choiceContainer.find("input").click(plot);
}

function plot() {
    var score_type = $("#score_type_select option:selected")[0].id;

    var selected_teams = [];
    var cbxs = $(".teamCheckbox:checked");
    for (var i = 0; i < cbxs.length; i++)
        selected_teams.push(cbxs[i].name);

    var data = extractChartFromHistory(score_type, selected_teams);
    
    var plot = $.plot($("#placeholder"), data, options_placeholder);

    // setup overview
    var overview = $.plot($("#overview"), data, options_overview);

    $("#placeholder").bind("plotselected", function(event, ranges) {
        plot = $.plot($("#placeholder"), data,
                      $.extend(true, {}, options_placeholder, {
                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
                      }));    
        overview.setSelection(ranges, true);
    });

    $("#overview").bind("plotselected", function(event, ranges) {
        plot = $.plot($("#placeholder"), data,
                      $.extend(true, {}, options_placeholder, {
                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
                      }));    
        //plot.setSelection(ranges, true);
    });
}

function extractChartFromHistory(score_type, selected_teams) {
    var data = [];
    if (h == null)
        return data;

    //if (score_type == "total")
    //    return data;

    var teams = h.teams;
    for (var team_N in teams) {
        if ($.inArray(teams[team_N].name, selected_teams) == -1)
            continue;
        var team = teams[team_N];
        data.push({ "label": team.name, "data": mergeArrays(h.round_times, team[score_type])});
        //data.push(mergeArrays(h.round_times, team[score_type]));
    }
    return data;
}

function mergeArrays(xArray, yArray) {
    var arr = [];
    for (var i = 0; i < xArray.length; i++)
        arr.push([xArray[i], yArray[i]]);

    return arr;
}

var options_placeholder = {
    legend: { show: true, position: 'nw' },
    series: {
        lines: { show: true },
        points: { show: true }
    },
    xaxis: { mode: "time", labelHeight: 32, ticks: 16, minTickSize: [1, "minute"] },
    yaxis: { ticks: 16, min: 0 },    
    selection: { mode: "x" },
    grid: {
        backgroundColor: { colors: ["#fff", "#eee"] }
    }

};

var options_overview = {
    legend: { show: false },
    series: {
        lines: { show: true, lineWidth: 1 },
        shadowSize: 0
    },
    xaxis: { mode: "time", ticks: 16 },
    yaxis: { ticks: 4, min: 0, autoscaleMargin: 0.1 },
    selection: { mode: "x" },
    grid: {
        backgroundColor: { colors: ["#fff", "#eee"] }
    }
};