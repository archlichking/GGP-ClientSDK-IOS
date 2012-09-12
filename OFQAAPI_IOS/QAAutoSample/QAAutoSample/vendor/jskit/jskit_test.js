(function() {
  var JskitTest, jskit, _ref;
  JskitTest = (function() {
    function JskitTest(protonApp, doc) {
      this.protonApp = protonApp;
      this.doc = doc;
    }
    JskitTest.prototype.appendTextNode = function(text) {
      var e, hr;
      e = this.doc.createTextNode(text);
      hr = this.doc.createElement('hr');
      this.doc.getElementById('resultText').appendChild(e);
      return this.doc.getElementById('resultText').appendChild(hr);
    };
    JskitTest.prototype.executeSuite = function(suite) {
      var func, params, _results;
      _results = [];
      for (func in suite) {
        params = suite[func];
        _results.push(this.functionCall(func, params, "this.appendTextNode('" + func + " test done')"));
      }
      return _results;
    };
    JskitTest.prototype.functionCall = function(name, params, callback) {
      var str;
      str = "this.protonApp.name(params, callback)";
      str = str.replace('name', name);
      if (params === "") {
        str = str.replace('params,', '');
      } else {
        str = str.replace('params,', params + ',');
      }
      str = str.replace('callback', callback);
      return eval(str);
    };
    JskitTest.prototype.invokeAllNonUITest = function() {
      var nonUISuite;
      nonUISuite = {
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
        'collateForDeposit': "",
        'contactForDeposit': "{'id':'101'}",
        'noticeLaunchDeposit': "",
        'pushViewWithURL': "'http://www.baidu.com'",
        'openExternalView': "'http://www.baidu.com'",
        'showMessageDialog': "{'buttons':['OK','Cancel'],'title':'ok cancel dialog','message':'this is message','cancel_index':1}",
        'needUpdate': "",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(nonUISuite));
      return this.executeSuite(nonUISuite);
    };
    JskitTest.prototype.invokePopupTest = function() {
      var popupSuite;
      popupSuite = {
        'showDashboardFromNotificationBoard': "",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeRequestPopup = function() {
      var popupSuite;
      popupSuite = {
        'showRequestDialog': "{'request':{'title':'request test','body':'request body'}}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeSharePopup = function() {
      var popupSuite;
      popupSuite = {
        'showShareDialog': "{'type':'normal', 'message':'normal dialog'}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeInvitePopup = function() {
      var popupSuite;
      popupSuite = {
        'showInviteDialog': "{'invite':{'body':'this is js invite'}}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeWebviewDialog = function() {
      var popupSuite;
      popupSuite = {
        'showWebViewDialog': "{'URL':'http://www.baidu.com','size':[50, 50]}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeDepositProductDialog = function() {
      var popupSuite;
      popupSuite = {
        'showDepositProductDialog': "",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeDepositHistoryDialog = function() {
      var popupSuite;
      popupSuite = {
        'showDepositHistoryDialog': "",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeNeedUpgrade = function() {
      var popupSuite;
      popupSuite = {
        'needUpgrade': "{'target_grade':'2'}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.invokeIAPHistoryDialog = function() {
      var popupSuite;
      popupSuite = {
        'closeAndLaunchIAPHistoryDialog': "",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(popupSuite));
      return this.executeSuite(popupSuite);
    };
    JskitTest.prototype.inviteExternalUser = function() {
      var viewSuite;
      viewSuite = {
        'inviteExternalUser': "{'URL':'http://www.baidu.com/'}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(viewSuite));
      return this.executeSuite(viewSuite);
    };
    JskitTest.prototype.showActionSheet = function() {
      var viewSuite;
      viewSuite = {
        'showActionSheetL': "{ 'title' : 'Alert',                               'buttons': ['OK', 'Do Nothing', 'Destroy All Buttons!', 'Cancel'],                               'cancel_index' : 2,                               'destructive_index' : 3}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(viewSuite));
      return this.executeSuite(viewSuite);
    };
    JskitTest.prototype.showAlertView = function() {
      var viewSuite;
      viewSuite = {
        'showAlertView': "{ 'title' : 'Alert',                             'message' : 'This is a message',                             'buttons': ['OK', 'Do Nothing', 'Cancel'],                             'cancel_index' : 0}",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(viewSuite));
      return this.executeSuite(viewSuite);
    };
    JskitTest.prototype.showDashboard = function() {
      var viewSuite;
      viewSuite = {
        'showDashboard': "{                           'URL':'http://www.google.com'                           }",
        'setConfig': "{'key':'jskitTestDone', 'value':'true'}"
      };
      console.log(JSON.stringify(viewSuite));
      return this.executeSuite(viewSuite);
    };
    return JskitTest;
  })();
  jskit = new JskitTest(proton.app, window.document);
    if ((_ref = window.jskit) != null) {
    _ref;
  } else {
    window.jskit = jskit;
  };
}).call(this);
