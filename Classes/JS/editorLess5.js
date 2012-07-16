/**
 * @author rechie
 */

var lastTarget;
var lastNode;
var lastParentNode;
var editMode = false;
var VK_ENTER = 13;
var WizNotCmdInditify = "<Wiznote-dzpqzb>";
var WizNotCmdChangedText = "changedText";
var WizNotCmdChangedImage = "changedImage";

String.prototype.replaceReturn = function() {
	return this.replace(/\n/g, "");
}
String.prototype.replaceSpace = function() {
	return this.replace(/\s+/g, " ");
}

Element.prototype.visible = function() {
	return this.style.display != "none"
};
Element.prototype.hide = function() {
	this.style.display = "none"
};
Element.prototype.show = function() {
	this.style.display = ""
	editMode = true;
};

function initHanler() {
	var a = document.body;
	if (!a) {
		//无body的处理
		return "document Error: No Body."
	}
	a.addEventListener("click", clickHandler);
	a.addEventListener("keydown", onKeyDown);
	// initEditor();
}

/**
 * 点击事件处理
 */
function clickHandler(e) {
	e.preventDefault();
	e.stopPropagation();
	e.stopImmediatePropagation();
	var j = e.target || e.srcElement;
	lastTarget = j;
	var sel = window.getSelection();
	if (sel && sel.rangeCount > 0) {
		var range = sel.getRangeAt(0);
		var minContainer = range.commonAncestorContainer;
		//文本节点处理
		if (minContainer.nodeType == document.TEXT_NODE) {
			var parent = minContainer.parent;
			lastNode = minContainer;
			lastParentNode = minContainer.parentNode;
			var text = minContainer.nodeValue.replaceReturn().replaceSpace();

			sendTextMessage(text);
			// selectBlock(minContainer);
		} else {
		}
	}
}

/**
 * 初始化editor
 */
function initEditor() {
	createElement("textarea", "editor", "wiz-editor", true)
	var editor = document.getElementById("editor");
	editor.addEventListener("keyDown", onKeyDown);
	editor.rows = 1;
}

/**
 * editor按钮监听事件，如果换行或回车按下时，当前editor不换行，直接保存当前行，并插入editor到该行下
 */
function onKeyDown(e) {
	var j = e.target || e.srcElement;
	if (j.id != "editor") {
		return;
	}
	if (e.keyCode == VK_ENTER) {
		done();
		event.preventDefault();
		event.stopPropagation();
		event.stopImmediatePropagation();
	}
	ResizeTextarea();
}

function createElement(t, i, c, h) {
	var a = document.body;
	var e = document.createElement(t);
	if (i) {
		e.id = i;
	}
	if (c) {
		e.className = c;
	}
	if (h) {
		e.hide();
	}

	if (a.firstElementChild) {
		a.insertBefore(e, a.firstElementChild)
	} else {
		a.appendChild(e)
	}
	return e;
}

function done() {
	var editor = document.getElementById("editor");
	var parent = lastNode.parentNode;
	lastNode.nodeValue = editor.value;
	lastParentNode.replaceChild(lastNode, editor);
	editMode = false;
	initEditor();
	// ShowObjProperty(editor);
}

/**
 * 去除并隐藏 textarea
 */
function hideEditor() {
	var a = $("editor");
	a.hide();
}

/**
 * 点击选中TextNode,进行处理
 */
function selectBlock(b) {
	if (!b) {
		return
	}
	lastE = b;
	var a = document.getElementById("editor");
	var parent = b.parentNode;
	parent.replaceChild(a, b);
	a.appendChild(b);
	var count = b.nodeValue.replaceReturn().replaceSpace();
	b.nodeValue = count;
	a.show();
}

function clearEditor() {
	var editor = document.getElementById("editor");
	editor.innerText = "";
}

function ResizeTextarea() {
	var a = document.getElementById("editor");
	var row = 1;
	var b = a.value.split("\n");
	var c = 0;
	c += b.length;
	var d = a.cols;
	if (d <= 20) {
		d = 40
	}
	for (var e = 0; e < b.length; e++) {
		if (b[e].length >= d) {
			c += Math.ceil(b[e].length / d)
		}
	}
	c = Math.max(c, row);
	if (c > a.rows) {
		a.rows = c;
	}
}

/**
 * 接受上层应用修改后的content，保存到当前修改的节点中
 */
function recieveResponseText(content) {
	if(!content) {
		return;
	}
	saveContent(content);
}

function saveContent(content) {
	lastNode.nodeValue = content;
}

function sendCmdToWiznote(cmd, content) {
	var url = WizNotCmdInditify + cmd + WizNotCmdInditify + content;
	// document.location = url;
}

/**
 * 发送点击的文字内容给上层
 * @param {Object} content
 */
function sendTextMessage(content) {
	sendCmdToWiznote(WizNotCmdChangedText, content);
}

document.addEventListener("DOMContentLoaded", initHanler, false); 
