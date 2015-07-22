define('login',function(require,exports,module){var _cacheThisModule_;var cookie=require("cookie");var ls=require("loadJs");exports.isLogin=isLogin
exports.validateLogin=function(callback,isBj){if(!isLogin()){callback(false);return true;}
validateLogin(callback,isBj);}
exports.login=login;function isLogin(){return document.domain.indexOf("jd.com")>=0?getWqUin()&&getWqSkey():getWgUin()&&getWgSkey();}
function validateLogin(callback,isBj,tryCount){if(typeof tryCount=="undefined")tryCount=1;isBj=isBj?isBj:document.domain.indexOf("jd.com")>=0;var checkCallback="validateLoginCallback";window[checkCallback]=function(data){callback(data.iRet!=9999)}
ls.loadScript((isBj?"http://wq.jd.com/mlogin/wxv3/LoginCheckJsonp":"http://party.wanggou.com/tws64/m/wxv3/LoginCheckJsonp")
+"?callback="+checkCallback+"&_t="+Math.random());}
function login(opt){var option={bj:false,env:getEnv(),rurl:location.href};for(var i in opt){option[i]=opt[i];}
document.domain.indexOf("jd.com")>=0&&(option.bj=true);if(option.env=="weixin"){location.href=(option.bj?"http://wq.jd.com/mlogin/wxv3/login_BJ?rurl=":"http://party.wanggou.com/tws64/m/wxv3/Login?rurl=")+encodeURIComponent(option.rurl)+"&appid=1";return true;}
else if(window.WQAPI&&option.env=="ycapp"){WQAPI.user.login(function(){if(option.rurl){if(option.rurl==location.href){location.reload();}
else{location.href=option.rurl;}}});}
else{location.href=(option.bj?"http://wq.jd.com/mlogin/h5v1/cpLogin_BJ":"http://party.wanggou.com/tws64/m/h5v1/cplogin")+"?rurl="+encodeURIComponent(option.rurl);}}
function getWgUin(){return cookie.get("wg_uin");}
function getWgSkey(){return cookie.get("wg_skey");}
function getWqUin(){return cookie.get("wq_uin");}
function getWqSkey(){return cookie.get("wq_skey");}
function getEnv(){var ua=navigator.userAgent.toLowerCase();if(/micromessenger(\/[\d\.]+)*/.test(ua)){return"weixin";}else if(/qq\/(\/[\d\.]+)*/.test(ua)||/qzone\//.test(ua)){return"qq";}else if(/jzyc/.test(ua)){return"ycapp";}else{return"h5";}}});
