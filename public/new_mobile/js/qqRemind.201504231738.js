define('qqRemind',function(require,exports,module){var _cacheThisModule_='',ls=require('loadJs'),login=require('login'),cookie=require('cookie'),uin=cookie.get('wq_uin')||cookie.get('wg_uin')||cookie.get('buy_uin')||'';cgi={set:'http://wq.jd.com/wqmsg/qqmsgrem/msgset?',clear:'http://wq.jd.com/wqmsg/qqmsgrem/msgclear?',query:'http://wq.jd.com/wqmsg/qqmsgrem/msgquery?'};exports.set=function(opt,cb){var cbName='setCallBack';ls.loadScript({url:cgi['set']+'uin='+uin+'&callback='+cbName+(typeof opt==='string'?opt:jsontostr(opt))+'&t='+Math.random(),charset:'utf-8'});window[cbName]=function(obj){if(obj.errcode==13){login.login();return;}
cb&&cb(obj);}}
exports.clear=function(opt,cb){var cbName='clearCallBack';ls.loadScript({url:cgi['clear']+'uin='+uin+'&callback='+cbName+'&itmeid='+opt.itmeid+'&t='+Math.random(),charset:'utf-8'});window[cbName]=function(obj){if(obj.errcode==13){login.login();return;}
cb&&cb(obj);}}
exports.query=function(opt,cb){var cbName='queryCallBack';ls.loadScript({url:cgi['query']+'uin='+uin+'&itmeid='+opt.itmeid+'&callback='+cbName+'&t='+Math.random(),charset:'utf-8'});window[cbName]=function(obj){if(obj.errcode==13){login.login();return;}
cb&&cb(obj);}}
function jsontostr(data){var s='';for(var k in data){s+='&'+k+'='+data[k];}
return s;}});
