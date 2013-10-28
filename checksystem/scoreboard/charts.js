var h;

var options = {
  legend: { show: true, position : 'nw' },
  series: {
    lines: { show: true },
    points: { show: true }
  },
//  yaxis: { ticks: 10 },
  xaxis: { mode: "time" },
  selection: { mode: "x" },
  grid: { markings: weekendAreas }
};


// helper for returning the weekends in a period
function weekendAreas(axes) {
    var markings = [];
    var d = new Date(axes.xaxis.min);
    // go to the first Saturday
    d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 1) % 7))
    d.setUTCSeconds(0);
    d.setUTCMinutes(0);
    d.setUTCHours(0);
    var i = d.getTime();
    do {
        // when we don't set yaxis, the rectangle automatically
        // extends to infinity upwards and downwards
        markings.push({ xaxis: { from: i, to: i + 2 * 24 * 60 * 60 * 1000} });
        i += 7 * 24 * 60 * 60 * 1000;
    } while (i < axes.xaxis.max);

    return markings;
}

function populateTeamsList(teams) {    
    var choiceContainer = $("#teams_list");
    $.each(teams, function(idx, val) {
        choiceContainer.append('<br/><input type="checkbox" name="' + val + '" id="' + val + '" class="teamCheckbox"><label>' + val + '</label>');
    });
    choiceContainer.find("input").click(plot);    
}

function getTeamsFromHistory() {
    var teams = [];
    for (var key in h.teams)
        teams.push(h.teams[key].name);
    return teams;
}

function addDataToHistory(data) {
  if (h == null) {
    h = data;
    populateTeamsList(getTeamsFromHistory());    
    return data.rounds.length > 0 ? data.rounds.length - 1 : 0;
  }
  
  h.seed = data.seed;
  
  var i;
  for (i = 0; i < h.rounds.length; i++)
    if (h.rounds[i] >= data.rounds[0])
      break;
      
  var last_round = 0;
  for (var j = 0; j < data.rounds.length; j++) {
    h.rounds[i+j] = data.rounds[j];
    h.round_times[i+j] = data.round_times[j];
    for (var team_N in data.teams) {
      var team = data.teams[team_N];
      h.teams[team_N].defense[i + j] = team.defense[j];
      h.teams[team_N].attack[i+j] = team.attack[j];
      h.teams[team_N].advisories[i+j] = team.advisories[j];
      h.teams[team_N].tasks[i+j] = team.tasks[j];
    }
    last_round = data.rounds[j];
  }

  var lengthWithTail = h.rounds.length;
  for (var j = lengthWithTail - 1; j >= h.rounds.length; j--) {
    h.rounds.pop();
    h.round_times.pop();
    for (var team_N in data.teams) {
      h.teams[team_N].defense.pop();
      h.teams[team_N].attack.pop();
      h.teams[team_N].advisories.pop();
      h.teams[team_N].tasks.pop();          
    }
  }
  
  return last_round;
}

function extractChartFromHistory(score_type, selected_teams) {
  var data = [];
  if (h == null)
    return data;
  
  if (score_type == "total")
    return data;
  
  var teams = h.teams;
  for (var team_N in teams) {
    if ($.inArray(teams[team_N].name, selected_teams) == -1)
      continue;
    var team = teams[team_N];
    //data.push({ "label": "'" + team.name + "_" + score_type + "'", "data": mergeArrays(h.round_times, team[score_type])});
    data.push(mergeArrays(h.round_times, team[score_type]));
  }
  return data;
}

function mergeArrays(xArray, yArray) {
  var arr = [];
  for (var i = 0; i < xArray.length; i++)
    arr.push([xArray[i], yArray[i]]);

  return arr;
}

function fetchData(round, seed) {
    $.ajax({
    url: "http://monitor.ructf.org/history?round=" + round + "&seed=" + seed + "&rnd=" + Math.random(),
    method: 'GET',
    dataType: 'json',
    success: onDataReceived,
    error: onFailDataReceive
  });
}

function onDataReceived(series, textStatus, XMLHttpRequest) {      
  //TODO ничо не делать, если данных не прилетело
  var lastRound = addDataToHistory(series);
  setTimeout("fetchData(" + lastRound + ", " + series.seed + ")", 5000);
  plot();
}

function onFailDataReceive(XMLHttpRequest, textStatus, errorThrown) {
  setTimeout("fetchData(0, 0)", 5000)
}


function plot() {
  var score_type = $("#score_type_select option:selected")[0].id;
  
  var selected_teams = [];
  var cbxs = $(".teamCheckbox:checked");
  for (var i = 0; i < cbxs.length; i++)
      selected_teams.push(cbxs[i].name);

  var data = extractChartFromHistory(score_type, selected_teams);
  var dd = [[[1196463600000, 0], [1196550000000, 0], [1196636400000, 0], [1196722800000, 77], [1196809200000, 3636], [1196895600000, 3575], [1196982000000, 2736], [1197068400000, 1086], [1197154800000, 676], [1197241200000, 1205], [1197327600000, 906], [1197414000000, 710], [1197500400000, 639], [1197586800000, 540], [1197673200000, 435], [1197759600000, 301], [1197846000000, 575], [1197932400000, 481], [1198018800000, 591], [1198105200000, 608], [1198191600000, 459], [1198278000000, 234], [1198364400000, 1352], [1198450800000, 686], [1198537200000, 279], [1198623600000, 449], [1198710000000, 468], [1198796400000, 392], [1198882800000, 282], [1198969200000, 208], [1199055600000, 229], [1199142000000, 177], [1199228400000, 374], [1199314800000, 436], [1199401200000, 404], [1199487600000, 253], [1199574000000, 218], [1199660400000, 476], [1199746800000, 462], [1199833200000, 448], [1199919600000, 442], [1200006000000, 403], [1200092400000, 204], [1200178800000, 194], [1200265200000, 327], [1200351600000, 374], [1200438000000, 507], [1200524400000, 546], [1200610800000, 482], [1200697200000, 283], [1200783600000, 221], [1200870000000, 483], [1200956400000, 523], [1201042800000, 528], [1201129200000, 483], [1201215600000, 452], [1201302000000, 270], [1201388400000, 222], [1201474800000, 439], [1201561200000, 559], [1201647600000, 521], [1201734000000, 477], [1201820400000, 442], [1201906800000, 252], [1201993200000, 236], [1202079600000, 525], [1202166000000, 477], [1202252400000, 386], [1202338800000, 409], [1202425200000, 408], [1202511600000, 237], [1202598000000, 193], [1202684400000, 357], [1202770800000, 414], [1202857200000, 393], [1202943600000, 353], [1203030000000, 364], [1203116400000, 215], [1203202800000, 214], [1203289200000, 356], [1203375600000, 399], [1203462000000, 334], [1203548400000, 348], [1203634800000, 243], [1203721200000, 126], [1203807600000, 157], [1203894000000, 288]]];
  
  // first correct the timestamps - they are recorded as the daily
  // midnights in UTC+0100, but Flot always displays dates in UTC
  // so we have to add one hour to hit the midnights in the plot
  //for (var i = 0; i < dd.length; ++i)
  //    dd[i][0] += 60 * 60 * 1000;


  var plot = $.plot($("#placeholder"), data, options);

  // setup overview
  var overview = $.plot($("#overview"), data, {
      series: {
          lines: { show: true, lineWidth: 1 },
          shadowSize: 0
      },
      xaxis: { ticks: [], mode: "time" },
      yaxis: { ticks: [], min: 0, autoscaleMargin: 0.1 },
      selection: { mode: "x" }
  });

  // now connect the two

  $("#placeholder").bind("plotselected", function(event, ranges) {
      // do the zooming
      plot = $.plot($("#placeholder"), data,
                      $.extend(true, {}, options, {
                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }                          
                      }));

      // don't fire event on the overview to prevent eternal loop
      overview.setSelection(ranges, true);
  });

  $("#overview").bind("plotselected", function(event, ranges) {
      plot = $.plot($("#placeholder"), data,
                      $.extend(true, {}, options, {
                          xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
                      }));
  });  
}

$(function() {
  
  fetchData(0, 0);  
});
