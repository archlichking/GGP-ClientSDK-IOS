var STEP_TIMEOUT = 250;
var STR_TEMPLATE = '{\"id\":\"#id\", \"tag\":\"#tag\", \"class\":\"#class\", \"text\":\"#text\", \"index\":\"#index\", \"src\":\"#src\"}';

function hl(e) {
    var d = e.style.outline;
    e.style.outline = '#FDFF47 solid';
    setTimeout(function () {
               e.style.outline = d
               }, STEP_TIMEOUT)
}
function fid(id) {
    return document.getElementById(id)
}
function fclass(clazz) {
    return document.getElementsByClassName(clazz)
}
function ftag(g) {
    return document.getElementsByTagName(g)
}
function click(e) {
    var t = document.createEvent('HTMLEvents');
    t.initEvent('click', false, false);
    setTimeout(function () {
               hl(e);
               setTimeout(function () {
                          e.dispatchEvent(t)
                          }, STEP_TIMEOUT)
               }, STEP_TIMEOUT)
}
function setText(e, t) {
    setTimeout(function () {
               hl(e);
               setTimeout(function () {
                          e.value = t
                          }, STEP_TIMEOUT)
               }, STEP_TIMEOUT)
}
function getText(e) {
    var r = e.value;
    if (r === '' || typeof (r) == 'undefined') {
        r = e.innerText
    }
    hl(e);
    return r
}
function stringify(es) {
    var r = '{elements:[';
    if (es.constructor == NodeList) {
        for (var i = 0; i < es.length; i++) {
            var ret = '';
            ret = STR_TEMPLATE.replace('#tag', es[i].tagName).replace('#id', es[i].getAttribute('id'))
                    .replace('#class', es[i].getAttribute('class')).replace('#text', getText(es[i]))
                    .replace('#index', i).replace('#src', es[i].getAttribute('src'));
            console.log(ret);
            r = r + ret + ','
        }
        r = r + ']}'
    } else {
        r = r + STR_TEMPLATE.replace('#tag', es.tagName).replace('#id', es.getAttribute('id'))
                .replace('#class', es.getAttribute('class')).replace('#text', getText(es))
                .replace('#index', 0).replace('#src', es.getAttribute('src')) + ']}'
    }
    return r
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