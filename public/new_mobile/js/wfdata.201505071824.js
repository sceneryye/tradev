define('wfdata',function(require,exports,module){var _cacheThisModule_,$=require('zepto'),ls=require('loadJs'),useDebug=JD.url.getUrlParam("debug")?true:false,storage=require("mqqStorage"),useCache=true,_DataType={MART:0,CPT:1,CPC:2,CPT_WX:3,MART_MUTI:4},myDomain='http://wq.jd.com',cgi=[myDomain+'/mcoss/mmart/show?',myDomain+'/mcoss/focuscpt/qqshow?',myDomain+'/mcoss/focusbi/show?',myDomain+'/mcoss/focuscpt/wxshow?',myDomain+'/mcoss/mmart/mshow?',];function getParamStr(param,isGetCacheKey){var arr=[];for(var key in param){var v=param[key];if(v!==null||v!==undefined){arr.push(isGetCacheKey?v:key+'='+v);}}
if(isGetCacheKey){arr.push('au');return arr.join('_');}else{arr.push('t='+Math.round(new Date()/(1000*300)));return arr.join('&');}}
function reportUtil(itilConfig){JD.report.itil(itilConfig);}
function _getData(opt){var cacheKey;if(useCache){cacheKey=opt.param.cacheKey||getParamStr(opt.param,true);storage.readH5Data(cacheKey,function(res,success){if(!success||!res){fetchData();return;}
opt.cb&&opt.cb(res);});}else{fetchData();}
function getCBName(cbName){if(!window[cbName]){return cbName;}else{return arguments.callee(cbName+'_1');}}
function fetchData(){var func=arguments.callee,args=arguments,context=this;var params=$.extend({},opt.param),cbName=opt.param.pi?(opt.param.callback+opt.param.pi):opt.param.callback;cbName=getCBName(cbName||'_cb_');params.callback=cbName;ls.loadScript({url:cgi[opt.dataType]+'&'+getParamStr(params),charset:'utf-8'});window[cbName]=function(obj){try{if(obj.errCode=="0"){if(obj.recovery&&parseInt(obj.recovery)>0){ls.loadScript({url:obj.recoveryUrl,charset:'utf-8'});return;}
opt.cb&&opt.cb(obj);if(useCache){storage.writeH5Data(cacheKey,obj,null,5);}}else{opt.utilFailed&&reportUtil(ppmsData.utilFailed);opt.handleError&&opt.handleError(func,args,context);}}catch(exp){if(useDebug){console.log('wf-data-error-begin.............');console.log(exp.message);console.log(exp.stack);console.log('...............error-end');}
opt.utilFailed&&reportUtil(ppmsData.utilFailed);opt.handleError&&opt.handleError(func,args,context);}};}}
exports.getData=function(opt){_getData(opt);}
exports.DataType=_DataType;});
