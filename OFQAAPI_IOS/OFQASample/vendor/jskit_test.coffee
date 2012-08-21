class JskitTest
	constructor: (@protonApp, @doc) ->

	appendTextNode: (text) ->
		e = @doc.createTextNode text
		hr = @doc.createElement 'hr'
		@doc.getElementById('resultText').appendChild(e)
		@doc.getElementById('resultText').appendChild(hr) 

	executeSuite: (suite) ->
		for func, params of suite
			@functionCall func, params, "this.appendTextNode('"+func+"  test done')"

	functionCall: (name, params, callback) ->
		str = "this.protonApp.name(params, callback)"
		str = str.replace 'name', name
		if params is ""
			str = str.replace 'params,', ''
		else
			str = str.replace 'params,', params + ','
		str = str.replace 'callback', callback
		eval(str)

	invokeAllNonUITest: () ->
		nonUISuite = 
			'setConfig': "{'key':'jsKitTest', 'value':'lay.zhu'}",
			'getConfig': "{'key':'jsKitTest'}",
			'setValue': "{'key':'jsKitTest', 'value':'lay.zhu'}",
			'getValue': "{'key':'jsKitTest'}",
			'getConfigList': "null",
			'getAppList': "{'schemes': ['greeapp12345', 'greeapp54321']}",
			'getViewInfo': "null",
			'startLog': "{'loglevel':'100'}",
			'stopLog': "{'loglevel':'100'}",
			'deleteCookie': "{'key':'baidu'}",
			'setLocalNotificationEnabled': "{'enabled':'true'}",
			'recordAnayticsData': "{'tp':'pg','pr':{'key_1':'val_1'},'fr':'yyy'}",
			'getContactList': "",
			'getLocalNotificationEnabled': "",
			'flushAnalyticsQueue': "",
			'flushAnalyticsData': "",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(nonUISuite)
		@executeSuite nonUISuite

	invokePopupTest: () ->
		popupSuite = 
			'showRequestDialog':"{'request':{'title':'request test','body':'request body'}}",
			'showShareDialog':"{'type':'normal', 'message':'normal dialog'}",
			'showInviteDialog': "{'invite':{'body':'this is js invite'}}",
			'showWebViewDialog':"{'URL':'http://www.baidu.com','size':[50, 50]}",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

	invokeRequestPopup: () ->
		popupSuite = 
			'showRequestDialog':"{'request':{'title':'request test','body':'request body'}}",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

	invokeSharePopup: () ->
		popupSuite = 
			'showShareDialog':"{'type':'normal', 'message':'normal dialog'}",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

	invokeInvitePopup: () ->
		popupSuite = 
			'showInviteDialog': "{'invite':{'body':'this is js invite'}}",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

	invokeWebviewDialog: () ->
		popupSuite = 
			'showWebViewDialog':"{'URL':'http://www.baidu.com','size':[50, 50]}",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

	invokeDepositProductDialog: () ->
		popupSuite = 
			'showDepositProductDialog': "",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

	invokeDepositHistoryDialog: ()->
		popupSuite = 
			'showDepositHistoryDialog': "",
			'setConfig': "{'key':'jskitTestDone', 'value':'true'}"

		console.log JSON.stringify(popupSuite)
		@executeSuite popupSuite

jskit = new JskitTest(proton.app, window.document)
window.jskit ? window.jskit = jskit