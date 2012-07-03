var STEP_TIMEOUT = 250;

function hl(e) {
	var d = e.style.outline;
	e.style.outline = '#FDFF47 solid';
	setTimeout(function() {
        e.style.outline = d;
    }, STEP_TIMEOUT);
}

function fid(id) {
	return document.getElementById(id);
}

function fclass(clazz) {
	return document.getElementsByClassName(clazz)[0];
}

function ftag(g, t) {
	var e = document.getElementsByTagName(g);
	for (var i = 0; i < e.length; i++) {
		if (e[i].innerText.indexOf(t) != -1) {
			return e[i];
		}
	}
}

function click(e) {
	var t = document.createEvent('HTMLEvents');
	t.initEvent('click', false, false);
	setTimeout(function() {
        hl(e);
        setTimeout(function() {
            e.dispatchEvent(t);
        }, STEP_TIMEOUT);
    }, STEP_TIMEOUT);
}

function setText(e, t) {
	setTimeout(function() {
        hl(e);
        setTimeout(function() {
            e.value = t;
        }, STEP_TIMEOUT);
    }, STEP_TIMEOUT);
}

function getText(e) {
	var r = e.value;
	if (r === '' || typeof(r) == 'undefined') {
		r = e.innerText;
	}
	hl(e);
	return r;
}

function waitPageLoading() {
	if ('complete' != document.readyState) {
		setTimeout(waitPageLoading, STEP_TIMEOUT);
	}
}

function assertEqual(exp, res) {
	return exp == res;
}

function assertContain(exp, res) {
	return res.search(exp) != -1
}

function assertExist(res) {
	return typeof(res) != 'undefined';
}

function assert(res) {
	return res;
}