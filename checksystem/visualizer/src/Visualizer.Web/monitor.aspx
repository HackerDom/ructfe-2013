<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>

<%
    try {
        // hint: query is 'filter={0}&time={1}&seed={2}'

        using (StreamReader file = new StreamReader (@"D:\monitor.dat")) {
            Response.Write (Request ["seed"] + "\n");
            long time = long.Parse (Request ["time"]);

            while (!file.EndOfStream) {
                string line = file.ReadLine ();
                string [] tokens = line.Split (new char [] { ' ' });

                if (tokens [0].Length == 1 && Request ["filter"] == "state")
                    if (long.Parse (tokens [1]) > time)
                        Response.Write (line + "\n");
                
                if (tokens [0].Length == 2 && Request ["filter"] == "scores")
                    if (long.Parse (tokens [1]) > time)
                        Response.Write (line + "\n");
            }
        }

    }
    catch {
        Response.Write (string.Empty);
    }
    Response.Flush ();
%>