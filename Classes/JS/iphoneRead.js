/**
 * @author wiz
 */

var script = document.createElement("style");
script.setAttribute("type", "text/css");
script.innerText = " img{width:320px;} li{list-style-type : none;margin:0; padding:0;}ul {margin:0; padding:0;} body {margin:0; padding:0;}";
document.head.appendChild(script);
var meta= document.createElement("meta"); 
meta.setAttribute('name','viewport');
meta.setAttribute('content','width=%@,initial-scale=1.0'); 
document.getElementsByTagName("head")[0].appendChild(meta);

