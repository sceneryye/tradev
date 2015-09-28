define('jd.address',function(require,exports,module){var _cacheThisModule_;var $=require('zepto'),ls=require('loadJs'),util=require('util'),storage_version='jd_search_areamap_201407',area=['全部'],areaId=['0'],level=0,cache={},cgiMonitor={areaTimer:null,timeout:5000};var opt={con:'filterBlock',deep:3,actClass:'',clickEvent:'tap',onClose:function(){}};module.exports={init:init,show:show,prev:prev};function init(option){$.extend(opt,option);bindEvent();};function show(lev){level=lev||0;getAreaList();}
function prev(){if(level<=0){opt.onClose();return;}
level--;getAreaList();}
function bindEvent(){if(opt.clickEvent==='click'&&opt.actClass){$('#'+opt.con).on('tap','[filter-type]',function(e){var tar=$(this);tar.addClass(opt.actClass);});}
$('#'+opt.con).on(opt.clickEvent,'[filter-type]',function(e){var tar=$(this),ftype=tar.attr('filter-type');if(ftype==='area'){var tid=tar.attr('tid'),tname=tar.attr('tname'),extid=tar.attr('extid');opt.actClass&&tar.addClass(opt.actClass);if(extid){level=parseInt(extid,10)+1;}else{level++;}
area[level]=tname;areaId[level]=tid;if(level<opt.deep&&level<4){opt.onSelect&&opt.onSelect(tid,tname,level);getAreaList();}
if(level>=opt.deep||level>=4){opt.onSelect&&opt.onSelect(tid,tname,level);finish();}}});}
function getAreaList(){var areaid=areaId[level];if(cache[areaid]&&cache[areaid].length>0){fillAreas(cache[areaid]);return;}
var areas=util.getStorage(storage_version);if(areas){areas=JSON.parse(areas);if(areas[areaid]&&areas[areaid].length>0){fillAreas(areas[areaid]);return;}}
var url='http://d.jd.com/area/get?fid='+areaid+'&callback=getAreaList_callback';window.getAreaList_callback=function(list){cgiMonitor.areaTimer&&window.clearTimeout(cgiMonitor.areaTimer);if(opt.itil){var repres=opt.itil.success;if(!list||list.length==0){repres=repres.concat(opt.itil.empty);}
try{util.itilReport({bid:opt.itil.bid,mid:opt.itil.mid,res:repres,delay:0});}catch(e){}}
var tempAreas=[];for(var i=0,len=list.length;i<len;++i){if(level==0){if(list[i].id>0&&list[i].id<100){tempAreas.push(list[i]);}}else{tempAreas.push(list[i]);}}
if(tempAreas.length>0){fillAreas(tempAreas);cache[areaid]=tempAreas;!areas&&(areas={});areas[areaid]=tempAreas;util.saveStorage(storage_version,areas,true);}else{if(level+1<areaId.length){for(var i=level+1,len=areaId.length;i<len;++i){delete areaId[i];delete area[i];}
areaId.length=level+1;area.length=level+1;}
finish();}};if(opt.itil){cgiMonitor.areaTimer=window.setTimeout(function(){try{util.itilReport({bid:opt.itil.bid,mid:opt.itil.mid,res:opt.itil.timeout,delay:0});}catch(e){}},cgiMonitor.timeout);}
ls.loadScript({url:url});}
function finish(){if(areaId[1]&&areaId[2]){util.setCookie('jdAddrId',areaId.slice(1).join('_'),999999,"/",'jd.com');util.saveStorage('jdAddrId',areaId.slice(1).join('_'));if(window.WQAPI)WQAPI.db.set('jdAddrId',areaId.slice(1).join('_'));}
if(area[1]&&area[2]){util.setCookie('jdAddrName',area.slice(1).join('_'),999999,"/",'jd.com');util.saveStorage('jdAddrName',area.slice(1).join('_'));if(window.WQAPI)WQAPI.db.set('jdAddrName',area.slice(1).join('_'));}
opt.onFinish&&opt.onFinish(area.slice(1),areaId.slice(1));}
function fillAreas(areas){if(opt.onRender){opt.onRender(areas,level);}else{var list=[];for(var i=0,len=areas.length;i<len;++i){list.push({datamark:'area',tid:areas[i].id,name:areas[i].name});}
var html=template(list);$('#'+opt.con).html(html);}
opt.onAfterRender&&opt.onAfterRender();}
function template(it){var out=['<ul class="mod_list">'];for(var i=0,l=it.length;i<l;i++){out.push('<li filter-type="'+(it[i].datamark)+'" tid="'+(it[i].tid)+'" tname="'+(it[i].name)+'"><span class="txt">'+it[i].name+'</span><i class="arr_area"></i></li>');}
out.push(['</ul>']);return out.join('');}});
