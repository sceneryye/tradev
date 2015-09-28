define('util',function(require,exports,module){var _cacheThisModule_;var $=require('zepto'),ls=require('loadJs');function checkInScreen(dom,offset,type){var pageHeight=document.documentElement.clientHeight,pageTop=$(document.body).scrollTop(),pageBottom=pageHeight+pageTop,dis=offset||0,size=dom.offset(),itemTop=size.top-dis,itemBottom=itemTop+size.height,checkType=type||'';if(type==='up'){if(itemBottom<pageTop){return true;}}else if(type==='down'){if(itemTop>pageBottom){return true;}}else{if((itemTop<pageBottom&&itemTop>pageTop)||(itemBottom<pageBottom&&itemBottom>pageTop)){return true;}else if(itemTop<pageTop&&itemBottom>pageBottom){return true;}}
return false;}
function delay(f,t){var now=Date.now,last=0,ctx,args,exec=function(){last=now();f.apply(ctx,args)};return function(){cur=now();ctx=this,args=arguments;if(cur-last>t){exec();}}}
function delegateMove(){var sy,direction,delegateFunc=[];this.listen=function(func){if(typeof func==='function'){delegateFunc.push(func);}};this.remove=function(func){if(typeof func!=='function')return;for(var i=0,l=delegateFunc.length;i<l;i++){if(func===delegateFunc[i]){delegateFunc.splice(i,1);}}};document.addEventListener('touchstart',function(e){var touches=e.touches[0];sy=touches.clientY;});document.addEventListener('touchmove',function(e){var touches=e.changedTouches[0],endTy=touches.clientY;if(endTy-sy>0){direction='up';}else if(sy-endTy>0){direction='down';}});document.addEventListener('touchend',delay(function(){fireFunc(direction);},80));document.addEventListener('scroll',delay(function(){fireFunc(direction);},80));function fireFunc(d){for(var i=0,l=delegateFunc.length;i<l;i++){delegateFunc[i].apply(null,[d]);}}}
function isDate(d){try{var d=new Date(d);d=null;return true;}catch(e){return false;}}
function format(s){var re=/{\d+}/g,args=Array.prototype.slice.call(arguments,1),r=s.toString();return r.replace(re,function(v){var vi=v.substr(1,v.length-2);return typeof args[vi]==='undefined'?v:args[vi];});}
function itilReport(option){var opt={bid:"1",mid:"01",res:[],onBeforeReport:null,delay:5000}
for(var k in option){opt[k]=option[k];}
if(opt.res.length>0){window.reportWebInfo=function(json){};window.setTimeout(function(){opt.onBeforeReport&&opt.onBeforeReport(opt);var pstr=opt.bid+opt.mid+"-"+opt.res.join("|");var url="http://bases.wanggou.com/mcoss/webreport/ReportWebInfo?report="+pstr+"&t="+new Date()/1000;ls.loadScript({url:url});},opt.delay);}}
function getQuery(name,url){var u=arguments[1]||window.location.search,reg=new RegExp("(^|&)"+name+"=([^&]*)(&|$)"),r=u.substr(u.indexOf("\?")+1).match(reg);return r!=null?r[2]:"";}
function setQuery(json,url){var hash=url?url.match(/#.*/)&&url.match(/#.*/)[0]||"":location.hash,search=url?url.replace(/#.*/,"").match(/\?.*/)&&url.replace(/#.*/,"").match(/\?.*/)[0]||"":location.search,path=url?url.replace(/#.*/,"").replace(/\?.*/,""):location.protocol+"//"+location.host+location.pathname;for(var i in json){var query=i+"="+json[i],oldValue=getQuery(i,search);if(oldValue){search=search.replace(i+"="+oldValue,i+"="+json[i]);}else{search=(search.length>0)?search+"&"+query:"?"+query;}}
return path+search+hash;}
function getCookie(name){var reg=new RegExp("(^| )"+name+"(?:=([^;]*))?(;|$)"),val=document.cookie.match(reg);return val?(val[2]?unescape(val[2]).replace(/(^")|("$)/g,""):""):null;}
function setCookie(name,value,expires,path,domain,secure){var exp=new Date(),expires=arguments[2]||null,path=arguments[3]||"/",domain=arguments[4]||null,secure=arguments[5]||false;expires?exp.setMinutes(exp.getMinutes()+parseInt(expires)):"";document.cookie=name+'='+escape(value)+(expires?';expires='+exp.toGMTString():'')+(path?';path='+path:'')+(domain?';domain='+domain:'')+(secure?';secure':'');}
function getHash(name){var u=arguments[1]||location.hash;var reg=new RegExp("(^|&)"+name+"=([^&]*)(&|$)");var r=u.substr(u.indexOf("#")+1).match(reg);if(r!=null){return r[2];}
return"";}
function htmlDecode(str){return typeof(str)!="string"?"":str.replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&quot;/g,"\"").replace(/&nbsp;/g," ").replace(/&#39;/g,"'").replace(/&amp;/g,"&");}
function htmlEncode(str){return typeof(str)!="string"?"":str.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\"/g,"&quot;").replace(/\'/g,"&apos;").replace(/ /g,"&nbsp;");}
function strSubGB(str,start,len,flag){var total=strLenGB(str);if(total>(len-start)){var flag=flag||"";var strTemp=str.replace(/[\u00FF-\uFFFF]/g,"@-").substr(start,len);var subLen=strTemp.match(/@-/g)?strTemp.match(/@-/g).length:0;return str.substring(0,len-subLen)+flag;}
return str;}
function strLenGB(v){return v.replace(/[\u00FF-\uFFFF]/g,"  ").length;}
function canWxPay(){var ua=navigator.userAgent.toLowerCase();return ua.match(/micromessenger/)?true:false;}
function removeStorage(key){window.localStorage.removeItem(key);}
function saveStorage(key,value,isJson){window.localStorage.setItem(key,isJson?JSON.stringify(value):value);}
function getStorage(key){return window.localStorage.getItem(key);}
function isSupportStorage(){if(!window.localStorage){return false;}
try{window.localStorage.setItem("test",true);window.localStorage.removeItem("test");return true;}catch(e){return false;}}
function isSQ(){var cid=getCookie('cid');if(cid==2)return true;if(/qq\/([\d\.]+)*/i.test(navigator.userAgent)){return true;}
return false;}
function isWX(){var cid=getCookie('cid');if(cid==1)return true;if(/MicroMessenger/i.test(navigator.userAgent)){return true;}
return false;}
function preventPageScroll(node){node[0].ontouchstart=handleStart;function handleStart(e){node[0].ontouchmove=handleMove;}
function handleMove(evt){evt.preventDefault();node[0].ontouchend=handleEnd;}
function handleEnd(){node[0].ontouchend=null;node[0].ontouchmove=null;}}
function loginLocation(url){if(getCookie('wg_uin')&&getCookie('wg_skey')){location.href=url;}
else{login(url);}}
function login(reUrl){reUrl=reUrl||location.href;if(isWX()){window.location.href='http://party.wanggou.com/tws64/m/wxv2/Login?appid=1&rurl='+encodeURIComponent(reUrl);}else{window.location.href='http://party.wanggou.com/tws64/m/h5v1/cpLogin?rurl='+encodeURIComponent(reUrl)+'&sid='+getCookie('sid')+'&uk='+getCookie('uk');}}
function addRd(url,rd){url=url.replace(/？/g,"?");var reg=/ptag[=,]\d+\.\d+\.\d+/i,hasQuery=/\?/.test(url);hasAnchor=url.indexOf('#')>-1;if(reg.test(url)){url=url.replace(reg,"PTAG="+rd);}else{url=hasAnchor?url.replace("#",(hasQuery?"&":"?")+"PTAG="+rd+"#"):(url+(hasQuery?"&":"?")+"PTAG="+rd);}
return url;}
function arrayUniq(arr){var returnArr=[];for(var i=0,len=arr.length;i<len;i++){((","+returnArr+",").indexOf(","+arr[i]+",")<0)?returnArr.push(arr[i]):'';};return returnArr;}
function once(fn){var run=false;return function(){!run&&(run=!run,typeof fn==='function'&&fn.call());}}
return{checkInScreen:checkInScreen,delay:delay,delegateMove:delegateMove,isDate:isDate,format:format,itilReport:itilReport,getQuery:getQuery,setQuery:setQuery,getCookie:getCookie,setCookie:setCookie,getHash:getHash,htmlDecode:htmlDecode,htmlEncode:htmlEncode,strSubGB:strSubGB,strLenGB:strLenGB,canWxPay:canWxPay,isSupportStorage:isSupportStorage,isSQ:isSQ,isWX:isWX,saveStorage:saveStorage,getStorage:getStorage,removeStorage:removeStorage,preventPageScroll:preventPageScroll,loginLocation:loginLocation,login:login,addRd:addRd,arrayUniq:arrayUniq,once:once};});
