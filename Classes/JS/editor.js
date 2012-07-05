var EditorDivID = 'editedContent';
function getDocumentEditedBodyHtml() {
    return document.getElementById(EditorDivID).innerHTML;
}
function getDocumentEditedBody()
{
	return document.getElementById(EditorDivID);
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
	root = getDocumentEditedBody();
	root.focus();
	
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


initRootElement();