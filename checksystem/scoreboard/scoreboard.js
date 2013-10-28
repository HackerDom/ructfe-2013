function checkBox_OnClick(position, sender_chk) {    
    var chk = document.getElementById("inFullScoreboard_chk" + position)
    if (chk != null)
        chk.checked = sender_chk.checked;
        
    var chk_2 = document.getElementById("inSelectedScoreboard_chk" + position)
    if (chk_2 != null)
        chk_2.checked = sender_chk.checked;
        
    if (sender_chk.checked) {
        var tr = document.getElementById("inSelectedScoreboard_" + position);
        if (tr != null) {
            for (var i = 0; i < tr.cells.length; i++) {
                tr.cells.item(i).style.display = "table-cell";
            }
            tr.className = "inFullScoreboard";
        }
        saveToCookie(position);
    }
    else {
        var tr = document.getElementById("inSelectedScoreboard_" + position);
        if (tr != null) {
            for (var i = 0; i < tr.cells.length; i++) {
                tr.cells.item(i).style.display = "none";
            }                        
            tr.className = "inSelectedScoreboard";
        }
        deleteFromCookie(position);
    }
}

function deleteFromCookie(number){
    var selectedTeamsStr = findCookie();
    if (selectedTeamsStr != ""){    
        var newArr = new Array();
        var arr = selectedTeamsStr.split(",");
        for (var i = 0; i < arr.length; i++)
            if (arr[i] != number)
                newArr.push(arr[i]);
        document.cookie = "selectedTeams = " + newArr.join(",");
    }
}

function saveToCookie(number) {
    var cookie = findCookie();
    if (cookie != "")
        cookie += ",";
    cookie += number;
    document.cookie = "selectedTeams = " + cookie;
}

function findCookie() {
    var cookie = document.cookie;
    var offset = cookie.indexOf("selectedTeams");
    if (offset != -1) {
        var end = cookie.indexOf(";", offset);
        if (end == -1)
            end = cookie.length;
        var arr = cookie.substring(offset, end).split(/\s*=\s*/);
        if (arr.length == 2)
            return arr[1];        
    }
    return "";
}

function restoreState() {
    var selectedTeamsStr = findCookie();
    if (selectedTeamsStr != ""){    
        var arr = selectedTeamsStr.split(",");
        for (var i = 0; i < arr.length; i++) {
            var tr = document.getElementById("inSelectedScoreboard_" + arr[i]);
            if (tr != null)
                tr.className = "inFullScoreboard";                
            var chk = document.getElementById("inFullScoreboard_chk" + arr[i]);
            if (chk != null)
                chk.checked = true;
            chk = document.getElementById("inSelectedScoreboard_chk" + arr[i]);
            if (chk != null)
                chk.checked = true;
        }        
    }
}

