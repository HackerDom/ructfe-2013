function my_getElementsByClassName(str ){
  var list = new Array();
  var nodes = document.getElementsByTagName('*');
  
  for (i = 0; i<nodes.length; i++){
    if (nodes[i].className.indexOf(str) >= 0 ){
      list.push(nodes[i]);
    }
  }

  return list;
}

function parse_emails(){
 var d = document.getElementsByTagName('a');
 var i;
 
 for(i=0;i<d.length;i++){
   if(/mailto:/.test(d[i].href) ? 1 : 0){d[i].href=d[i].href.replace("[at]", "@");}
 }
 
 d = my_getElementsByClassName('email');
 
 for(i=0;i<d.length;i++){
   d[i].innerHTML=d[i].innerHTML.replace("[at]", "@");
 }
}