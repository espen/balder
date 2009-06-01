/*
Copyright (c) 2009 Ronnie Garcia, Travis Nickels

This file is part of Uploadify v1.6.2

Permission is hereby granted, free of charge, to any person obtaining a copy
of Uploadify and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

UPLOADIFY IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

var flashVer = -1;
if (navigator.plugins != null && navigator.plugins.length > 0) {
	if (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"]) {
		var swVer2 = navigator.plugins["Shockwave Flash 2.0"] ? " 2.0" : "";
		var flashDescription = navigator.plugins["Shockwave Flash" + swVer2].description;
		var descArray = flashDescription.split(" ");
		var tempArrayMajor = descArray[2].split(".");			
		var versionMajor = tempArrayMajor[0];
		var versionMinor = tempArrayMajor[1];
		var versionRevision = descArray[3];
		if (versionRevision == "") {
			versionRevision = descArray[4];
		}
		if (versionRevision[0] == "d") {
			versionRevision = versionRevision.substring(1);
		} else if (versionRevision[0] == "r") {
			ersionRevision = versionRevision.substring(1);
			if (versionRevision.indexOf("d") > 0) {
				versionRevision = versionRevision.substring(0, versionRevision.indexOf("d"));
			}
		}
		var flashVer = versionMajor + "." + versionMinor	 + "." + versionRevision;
	}
} else if ( $.browser.msie ) {
	var version;
	var axo;
	var e;
	try {
		axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");
		version = axo.GetVariable("$version");
	} catch (e) {
	}	
	flashVer = version.replace("WIN ","").replace(",",".");
}
flashVer = flashVer.split(".")[0];

if(jQuery)(
	function($){
		$.extend($.fn,{
			fileUpload:function(options) {
				if (flashVer >= 9) {
					$(this).each(function(){
						settings = $.extend({
						uploader:      'uploader.swf',
						script:        'uploader.php',
						folder:        '',
						height:        30,
						width:         110,
						cancelImg:     'cancel.png',
						wmode:         'opaque',
						scriptAccess:  'sameDomain',
						fileDataName:  'Filedata',
						displayData:   'percentage',
						onInit:        function() {},
						onSelect:      function() {},
						onCheck:       function() {},
						onCancel:      function() {},
						onError:       function() {},
						onProgress:    function() {},
						onComplete:    function() {}
					}, options);
					var pagePath = location.pathname;
					pagePath = pagePath.split('/');
					pagePath.pop();
					pagePath = pagePath.join('/') + '/';
					var data = '&pagepath=' + pagePath;
					if (settings.buttonImg) data += '&buttonImg=' + escape(settings.buttonImg);
					if (settings.buttonText) data += '&buttonText=' + escape(settings.buttonText);
					if (settings.rollover) data += '&rollover=true';
					data += '&script=' + settings.script;
					data += '&folder=' + escape(settings.folder);
					if (settings.scriptData) {
						var scriptDataString = '';
						for (var name in settings.scriptData) {
							scriptDataString += '&' + name + '=' + settings.scriptData[name];
						}
						data += '&scriptData=' + escape(scriptDataString); 
					}
					data += '&btnWidth=' + settings.width;
					data += '&btnHeight=' + settings.height;
					data += '&wmode=' + settings.wmode;
					if (settings.hideButton) data += '&hideButton=true';
					if (settings.fileDesc) data += '&fileDesc=' + settings.fileDesc + '&fileExt=' + settings.fileExt;
					if (settings.multi) data += '&multi=true';
					if (settings.auto) data += '&auto=true';
					if (settings.sizeLimit) data += '&sizeLimit=' + settings.sizeLimit;
					if (settings.simUploadLimit) data += '&simUploadLimit=' + settings.simUploadLimit;
					if (settings.checkScript) data += '&checkScript=' + settings.checkScript;
					if (settings.fileDataName) data += '&fileDataName=' + settings.fileDataName;
					if ($.browser.msie) {
						flashElement = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="' + settings.width + '" height="' + settings.height + '" id="' + $(this).attr("id")  + 'Uploader" class="fileUploaderBtn">\
						<param name="movie" value="' + settings.uploader + '?fileUploadID=' + $(this).attr("id") + data + '" />\
						<param name="quality" value="high" />\
						<param name="wmode" value="' + settings.wmode + '" />\
						<param name="allowScriptAccess" value="' + settings.scriptAccess + '">\
						<param name="swfversion" value="9.0.0.0" />\
						</object>';
					} else {
						flashElement = '<embed src="' + settings.uploader + '?fileUploadID=' + $(this).attr("id") + data + '" quality="high" width="' + settings.width + '" height="' + settings.height + '" id="' + $(this).attr("id") + 'Uploader" class="fileUploaderBtn" name="' + $(this).attr("id") + 'Uploader" allowScriptAccess="' + settings.scriptAccess + '" wmode="' + settings.wmode + '" type="application/x-shockwave-flash" />';
					}
					if (settings.onInit() !== false) {
						$(this).css('display','none');
						if ($.browser.msie) {
							$(this).after('<div id="' + $(this).attr("id")  + 'Uploader"></div>');
							document.getElementById($(this).attr("id")  + 'Uploader').outerHTML = flashElement;
						} else {
							$(this).after(flashElement);
						}
						$("#" + $(this).attr('id') + "Uploader").after('<div id="' + $(this).attr('id') + 'Queue" class="fileUploadQueue"></div>');
					}
					$(this).bind("rfuSelect", {'action': settings.onSelect}, function(event, queueID, fileObj) {
						if (event.data.action(event, queueID, fileObj) !== false) {
							var byteSize = Math.round(fileObj.size / 1024 * 100) * .01;
							var suffix = 'KB';
							if (byteSize > 1000) {
								byteSize = Math.round(byteSize *.001 * 100) * .01;
								suffix = 'MB';
							}
							var sizeParts = byteSize.toString().split('.');
							if (sizeParts.length > 1) {
								byteSize = sizeParts[0] + '.' + sizeParts[1].substr(0,2);
							} else {
								byteSize = sizeParts[0];
							}
							if (fileObj.name.length > 20) {
								fileName = fileObj.name.substr(0,20) + '...';
							} else {
								fileName = fileObj.name;
							}
							$('#' + $(this).attr('id') + 'Queue').append('<div id="' + $(this).attr('id') + queueID + '" class="fileUploadQueueItem">\
									<div class="cancel">\
										<a href="javascript:$(\'#' + $(this).attr('id') + '\').fileUploadCancel(\'' + queueID + '\')"><img src="' + settings.cancelImg + '" border="0" /></a>\
									</div>\
									<span class="fileName">' + fileName + ' (' + byteSize + suffix + ')</span><span class="percentage">&nbsp;</span>\
									<div class="fileUploadProgress" style="width: 100%;">\
										<div id="' + $(this).attr('id') + queueID + 'ProgressBar" class="fileUploadProgressBar" style="width: 1px; height: 3px;"></div>\
									</div>\
								</div>');
						}
					});
					if (typeof(settings.onSelectOnce) == 'function') {
						$(this).bind("rfuSelectOnce", settings.onSelectOnce);
					}
					$(this).bind("rfuCheckExist", {'action': settings.onCheck}, function(event, checkScript, fileQueue, folder, single) {
						var postData = new Object();
						postData.folder = pagePath + folder;
						for (var queueID in fileQueue) {
							postData[queueID] = fileQueue[queueID];
							if (single) {
								var singleFileID = queueID;
							}
						}
						$.post(checkScript, postData, function(data) {
							for(var key in data) {
								if (event.data.action(event, checkScript, fileQueue, folder, single) !== false) {
									var replaceFile = confirm('Do you want to replace the file \'' + data[key] + '\'?');
									if (!replaceFile) {
										document.getElementById($(event.target).attr('id') + 'Uploader').cancelFileUpload(key);
									}
								}
							}
							if (single) {
								document.getElementById($(event.target).attr('id') + 'Uploader').startFileUpload(singleFileID, true);
							} else {
								document.getElementById($(event.target).attr('id') + 'Uploader').startFileUpload(null, true);
							}
						}, "json");
					});
					$(this).bind("rfuCancel", {'action': settings.onCancel}, function(event, queueID, fileObj, data) {
						if (event.data.action(event, queueID, fileObj, data) !== false) {
							$("#" + $(this).attr('id') + queueID).fadeOut(250, function() { $("#" + $(this).attr('id') + queueID).remove()});
						}
					});
					$(this).bind("rfuClearQueue", {'action': settings.onClearQueue}, function() {
						if (event.data.action() !== false) {
							$('#' + $(this).attr('id') + 'Queue').contents().fadeOut(250, function() {$('#' + $(this).attr('id') + 'Queue').empty()});
						}
					});
					$(this).bind("rfuError", {'action': settings.onError}, function(event, queueID, fileObj, errorObj) {
						if (event.data.action(event, queueID, fileObj, errorObj) !== false) {
							$("#" + $(this).attr('id') + queueID + " .fileName").text(errorObj.type + " Error - " + fileObj.name);
							$("#" + $(this).attr('id') + queueID).css({'border': '3px solid #FBCBBC', 'background-color': '#FDE5DD'});
						}
					});
					$(this).bind("rfuProgress", {'action': settings.onProgress, 'toDisplay': settings.displayData}, function(event, queueID, fileObj, data) {
						if (event.data.action(event, queueID, fileObj, data) !== false) {
							$("#" + $(this).attr('id') + queueID + "ProgressBar").css('width', data.percentage + '%');
							if (event.data.toDisplay == 'percentage') displayData = ' - ' + data.percentage + '%';
							if (event.data.toDisplay == 'speed') displayData = ' - ' + data.speed + 'KB/s';
							if (event.data.toDisplay == null) displayData = ' ';
							$("#" + $(this).attr('id') + queueID + " .percentage").text(displayData);
						}
					});
					$(this).bind("rfuComplete", {'action': settings.onComplete}, function(event, queueID, fileObj, response, data) {
						if (event.data.action(event, queueID, fileObj, unescape(response), data) !== false) {
							$("#" + $(this).attr('id') + queueID).fadeOut(250, function() { $("#" + $(this).attr('id') + queueID).remove()});
							$("#" + $(this).attr('id') + queueID + " .percentage").text(' - Completed');
						}
					});
					if (typeof(settings.onAllComplete) == 'function') {
						$(this).bind("rfuAllComplete", settings.onAllComplete);
					}
				});
			}
		},
		fileUploadSettings:function(settingName, settingValue) {
			$(this).each(function() {
				document.getElementById($(this).attr('id') + 'Uploader').updateSettings(settingName,settingValue);
			});
		},
		fileUploadStart:function(queueID) {
			$(this).each(function() {
				document.getElementById($(this).attr('id') + 'Uploader').startFileUpload(queueID, false);
			});
		},
		fileUploadCancel:function(queueID) {
			$(this).each(function() {
				document.getElementById($(this).attr('id') + 'Uploader').cancelFileUpload(queueID);
			});
		},
		fileUploadClearQueue:function() {
			$(this).each(function() {
				document.getElementById($(this).attr('id') + 'Uploader').clearFileUploadQueue();
			});
		}
	})
})(jQuery);