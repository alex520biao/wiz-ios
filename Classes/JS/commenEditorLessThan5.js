var EditorDivID = 'editedContent';
var WizNotCmdInditify = "<Wiznote-dzpqzb>";
var WizNotCmdChangedText = "changedText";
var WizNotCmdChangedImage = "changedImage";
var WizDeleteImageSpanName = "WizDeleteImageSpan";
var needChangedNode = '';
var currentSelectImage ='';

function sendCmdToWiznote(cmd,content)
{
    var url =WizNotCmdInditify + cmd + WizNotCmdInditify + content;
    document.location = url;
}
function sendChangedTextMessage(content)
{
    sendCmdToWiznote(WizNotCmdChangedText,content);
}
$(function() {
  $('wiz').click(function(e) {
                 needChangedNode = e.target;
                 sendChangedTextMessage(e.target.innerHTML);
                 return false;
                 });
  });

function clearjquery() {
    $('*').unbind();
}
function endFix(result) {
    needChangedNode.innerHTML = result;
}
function getDocumentEditedBodyHtml() {
    return document.getElementById(EditorDivID).innerHTML;
}
function getDocumentEditedBody()
{
	return document.body;
}
function focusEditor()
{
    document.getElementById(EditorDivID).focus();
}
function initRootElement() {
    var span = document.createElement("div");
    span.setAttribute("id", EditorDivID);
    span.setAttribute("contenteditable", "true")
    span.innerHTML = document.body.innerHTML;
    document.body.innerHTML = '';
    document.body.appendChild(span);
}
function insertPhoto(path)
{
	root = document.body;
	img = document.createElement('img');
	img.setAttribute('src',path);
	
	root.appendChild(img);
}
function insertAudio(path)
{
	root = getDocumentEditedBody();
	root.focus();
	audio = document.createElement('embed');
	audio.setAttribute('src',path);
	audio.setAttribute('autostart',false);
	root.appendChild(audio);
	// embed src=\"index_files/%@\" autostart=false
}
function copyAttributes(source, aim)
{
	var attributes = source.attributes;
	for(i=0;i <attributes.length; i++)
	{
		var item = attributes.item(i);
		aim.setAttribute(item.name, item.value);
	}
}

//function deleteImage()
//{
//    var deleteImageSpan = document.createElement(WizDeleteImageSpanName);
//    copyAttributes(currentSelectImage, deleteImageSpan);
//	currentSelectImage.parentElement.replaceChild(deleteImageSpan, currentSelectImage);
//}

function deleteImage()
{
    currentSelectImage.parentElement.removeChild(currentSelectImage);
}

function clickOnImage(e) {
    var targ
    if(!e)
        var e = window.event
    if(e.target)
        targ = e.target
    else if(e.srcElement)
        targ = e.srcElement
    if(targ.nodeType == 3)// defeat Safari bug
        targ = targ.parentNode
    var tname
    tname = targ.tagName
    if (tname == 'IMG')
    {
        currentSelectImage = targ;
        sendCmdToWiznote(WizNotCmdChangedImage,targ.src)
    };
}

document.body.addEventListener('click',clickOnImage);