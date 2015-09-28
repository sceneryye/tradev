define("report",function(require,exports,module){var _cacheThisModule_;var REPORT_VERSON='1.1',goodsExposureList=[],logJSONList=[];function extend(target,source){for(var key in source){target[key]=source[key];}}
function $getCookie(name){var reg=new RegExp("(^| )"+name+"(?:=([^;]*))?(;|$)"),val=document.cookie.match(reg);return val?(val[2]?unescape(val[2]):""):null;}
function pvReport(bjInfo,szInfo){try{window.MANUAL_PV=true;if(!bjInfo){return;}
if(!(window.ECC_cloud_report_pv&&FOOTDETECT&&FOOTDETECT.objMsgPv)){setTimeout(function(){pvReport(bjInfo,szInfo);},50);return;}
var objData={};extend(objData,FOOTDETECT.objMsgPv||{});if(bjInfo.vurl){extend(objData,bjInfo);window._vurl=bjInfo.vurl;ECC.cloud.report.pvPortal(objData);}else{if(szInfo){window.jdPvLog(bjInfo);extend(objData,szInfo);ECC.cloud.report.pv(objData);}else{window.jdPvLog(bjInfo);extend(objData,bjInfo);ECC.cloud.report.pv(objData);}}}catch(e){}}
function pvPortal(vurl){if(typeof vurl!='string'){return;}
var ptag=/[&?]ptag=([^&#]*)/gi.exec(vurl);ptag=ptag?ptag[1]:'';pvReport({vurl:vurl,ptag:ptag});}
function logJSON(obj){function task(){if(!task.hasInit){task.counter=setInterval(function(){if(window.ECC_cloud_report_pv){if(!logJSONList.length){clearInterval(task.counter);task.counter=0;return;}
var data=logJSONList.shift();log(data);}},40);task.hasInit=true;}}
function log(data){var mark='wg_wx.000002';data.mark&&(mark=data.mark,delete data.mark);window.ja&&window.ja.logJSON(mark,REPORT_VERSON,data);}
if(window.ECC_cloud_report_pv){log(obj);}else{if(!obj||({}).toString.call(obj)!='[object Object]'){return;}
logJSONList.push(obj);task();}}
function setCookiePtag(ptag){if(!window.ECC_cloud_report_pv){setTimeout(function(){setCookiePtag(ptag);},100);return;}
setTimeout(function(){ECC.cloud.report.synCookiePtag({ptag:ptag,notNeedPvReport:true});},200);}
function getPPRD_PValue(prefix){var regs={QZGDT:/QZGDT\.([^\.\-]+)/gim,QZZTC:/QZZTC\.([^\.\-]+)/gim,ADKEY:/ADKEY\.([^\.\-]+)/gim,WQVERSION:/WQVERSION\.([^\.\-]+)/gim},pprd_p=$getCookie('PPRD_P')||'',paramIsArr=Array.isArray(prefix),str='',rs={};prefix=paramIsArr?prefix:[prefix];pprd_p&&prefix.forEach(function(elem){if(regs[elem]&&regs[elem].test(pprd_p)){rs[elem]=RegExp.$1||'';}});return paramIsArr?rs:rs[prefix[0]];}
function logGoodsExposure(ptags){function task(){if(!logGoodsExposure.hasInit){logGoodsExposure.counter=setInterval(function(){if(window.ECC_cloud_report_pv){clearInterval(logGoodsExposure.counter);logGoodsExposure.counter=0;log();}},80);logGoodsExposure.hasInit=true;}}
function log(){if(!goodsExposureList.length){return;}
window.ja&&window.ja.logGoodsExposure(goodsExposureList.join('_'));logGoodsExposure.goodsExposureList=goodsExposureList=[];}
if(!ptags){return;}!logGoodsExposure.goodsExposureList&&(logGoodsExposure.goodsExposureList=[]);!Array.isArray(ptags)&&(ptags=[ptags]);var goodsExposureList=logGoodsExposure.goodsExposureList;[].push.apply(goodsExposureList,ptags);if(window.ECC_cloud_report_pv){log();}else{task();}}
function logShopJSON(data){data=data||{};data.mark='wg_wx.000004';logJSON(data);}
function trace(data){if(!window.ECC_cloud_report_pv){return;}
window.ja&&window.ja.trace(data);}
exports.pvReport=pvReport;exports.pvPortal=pvPortal;exports.trace=trace;exports.logJSON=logJSON;exports.logGoodsExposure=logGoodsExposure;exports.logShopJSON=logShopJSON;exports.setCookiePtag=setCookiePtag;exports.getADKEY=function(){return getPPRD_PValue('ADKEY')||'';}});
