/**
 * 发行全局公共方法与公共变量，公共方法修改时一定要兼容以前的方法，避免导致使用旧方法的平台报错
 * @version v2.0
 * @author hlb
 * @description 本文件将压缩进每个发行平台文件，为避免一些研发还没加载完公共文件就开始执行发行jssdk方法
 */
window.SQFUNC = {
  /**
   * 动态加载js并执行callback方法
   * @param  {String}   src      js-sdk链接
   * @param  {function} callback 加载完js后的回调函数
   * @return {[type]}            [description]
   */
  loadScript: function(src, callback) {
    var that = this;
    var scriptO = document.createElement('script');
    scriptO.src = src;
    scriptO.onload = scriptO.onreadystatechange = function() {
      if (!this.readyState || this.readyState === "loaded" || this.readyState === "complete") {
        if (callback && typeof callback === "function") {
          callback();
        }
        // Handle memory leak in IE
        scriptO.onload = scriptO.onreadystatechange = null;
      }
    };
    document.body.appendChild(scriptO);
  },
  /**
   * 是否是可点击——对应moveevent，false为不可点击，正在拖动状态,true为可点击
   * @type {Object}
   */
  touchFlag: {},
  /**
   * 可拖动事件，传入dom-id
   * @type {[type]}
   */
  moveEvent: function(id) {
    var that = this;
    if (!document.getElementById(id)) {
      return;
    }
    // 获取节点
    var glTouch = document.getElementById(id),
      glTouchW = glTouch.offsetWidth,
      halfW = document.body.clientWidth / 2;

    that.touchFlag[id] = true;

    var oW, oH;
    var oLeft, oTop, flag;
    var evtNames = {
      evt1: "touchstart",
      evt2: "touchmove",
      evt3: "touchend"
    };
    if (!that.isPhone()) {
      evtNames = {
        evt1: "mousedown",
        evt2: "mousemove",
        evt3: "mouseup"
      };
    }
    oLeft = document.documentElement.clientWidth - glTouchW;

    // 绑定touchstart事件
    glTouch.addEventListener(evtNames.evt1, function(e) {
      flag = true;

      var touches = e.touches ? e.touches[0] : {
        "clientX": e.clientX,
        "clientY": e.clientY
      };
      oW = touches.clientX - glTouch.offsetLeft;
      oH = touches.clientY - glTouch.offsetTop;
      //阻止页面的滑动默认事件
      document.addEventListener(evtNames.evt2, defaultEvent(e), false);
      document.addEventListener(evtNames.evt2, function(e) {
        if (!flag) {
          return;
        }
        that.touchFlag[id] = false;
        var touches = e.touches ? e.touches[0] : {
          "clientX": e.clientX,
          "clientY": e.clientY
        };
        oLeft = touches.clientX - oW;
        oTop = touches.clientY - oH;
        if (oLeft < 0) {
          oLeft = 0;
        } else if (oLeft > document.documentElement.clientWidth - document.getElementById(id).offsetWidth) {
          oLeft = document.documentElement.clientWidth - document.getElementById(id).offsetWidth;
        }
        if (oTop < 0) {
          oTop = 0;
        } else if (oTop > (document.documentElement.clientHeight || document.body.clientHeight) - glTouch.offsetHeight) {
          oTop = (document.documentElement.clientHeight || document.body.clientHeight) - glTouch.offsetHeight;
        }

        glTouch.style.left = oLeft + "px";
        glTouch.style.top = oTop + "px";
      }, false);
    }, false);
    glTouch.addEventListener(evtNames.evt3, function(e) {
      flag = false;
      if (oLeft == document.documentElement.clientWidth || oLeft == document.documentElement.clientHeight) {} else if (oLeft > halfW) {
        // glTouch.style.left = oLeft + "px";
        glTouch.style.left = "auto";
        glTouch.style.right = "0";
      } else {
        glTouch.style.left = "0";
        glTouch.style.right = "auto";
      }
      glTouch.style.top = oTop + "px";

      //阻止页面的滑动默认事件
      document.addEventListener(evtNames.evt2, defaultEvent(e), false);
      document.removeEventListener(evtNames.evt2, defaultEvent(e), false);
      setTimeout(function() {
        that.touchFlag[id] = true;
      }, 15);
    }, false);

    function defaultEvent(e) {}
  },
  /**
   * 是否是手机
   * @return {[type]} [description]
   */
  isPhone: function() {
    var ua = navigator.userAgent.toLocaleLowerCase(),
      is_iPd = ua.match(/(ipad|ipod|iphone)/i) != null,
      is_mobile = !!ua.match(/applewebkit.*mobile.*/),
      is_mobi = ua.toLowerCase().match(/(ipod|iphone|android|coolpad|mmp|smartphone|midp|wap|xoom|symbian|j2me|blackberry|win ce)/i) != null,
      is_mobi = is_iPd || is_mobi || is_mobile;
    return is_mobi;
  },
  /**
   * 判断是否是QQ环境
   * @return {[type]} [description]
   */
  isQQ: function() {
    return (navigator.userAgent.toLowerCase().match(/\bqq\b/i) == "qq");
  },
  /**
   * 判断是否是微信环境
   * @return {[type]} [description]
   */
  isWechat: function() {
    return (navigator.userAgent.toLowerCase().match(/MicroMessenger/i) == "micromessenger");
  },
  /**
   * 判断是否是安卓环境
   * @return {[type]} [description]
   */
  isAndroid: function() {
    return navigator.userAgent.indexOf("Android") > -1 || navigator.userAgent.indexOf("Linux") > -1;
  },
  /**
   * 判断是否是IOS设备
   * @return {[type]} [description]
   */
  isiOS: function() {
    return !!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
  },
  /**
   * 判断是否是PC微信环境
   * @return {[type]} [description]
   */
  isPCWeixin: function() {
    return (navigator.userAgent.toLowerCase().match(/WindowsWechat/i) == "windowswechat");
  },
  /**
   * 原生ajax方法
   * @return {[type]} [description]
   */
  ajax: function(options) {
    var that = this,
      params,
      options = options || {};

    options.type = (options.type || "GET").toUpperCase();
    options.dataType = options.dataType || "json";
    params = that.formatParams(options.data);

    //创建 - 非IE6 - 第一步
    if (window.XMLHttpRequest) {
      var xhr = new XMLHttpRequest();
    } else { //IE6及其以下版本浏览器
      var xhr = new ActiveXObject('Microsoft.XMLHTTP');
    }

    //接收 - 第三步
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        var status = xhr.status;
        if (status >= 200 && status < 300) {
          options.success && options.success(xhr.responseText, xhr.responseXML);
        } else {
          options.fail && options.fail(status);
        }
      }
    }

    //连接 和 发送 - 第二步
    if (options.type == "GET") {
      xhr.open("GET", options.url + "?" + params, true);
      xhr.send(null);
    } else if (options.type == "POST") {
      xhr.open("POST", options.url, true);
      //设置表单提交时的内容类型
      xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      xhr.send(params);
    }
  },
  /**
   * jsonp请求
   * @param  {Object} options [description]
   *   {String} url 接口地址 必要
   *   {String} callback 传递的函数名 必要
   *   {String} data 数据参数
   *   {function} success 成功函数
   *   {function} fail 失败函数
   *   {Int} timeout 超时时间
   * @return {[type]}         [description]
   */
  jsonp: function(options) {
    var that = this;
    options = options || {};
    if (!options.url) {
      throw new Error("参数不合法");
    }
    if (!options.callback) {
      options.callback = 'callback';
    }
    //创建 script 标签并加入到页面中
    var callbackName = ('jsonp_' + Math.random()).replace(".", "");
    var oHead = document.getElementsByTagName('head')[0];
    options.data[options.callback] = callbackName;
    var params = that.formatParams(options.data);
    var oS = document.createElement('script');
    oHead.appendChild(oS);

    //创建jsonp回调函数
    window[callbackName] = function(json) {
      oHead.removeChild(oS);
      if (oS.timer) {
        clearTimeout(oS.timer);
      }
      window[callbackName] = null;
      options.success && options.success(json);
    };
    var urltype = (/\?/.test(options.url)) ? '&' : '?';
    //发送请求
    oS.src = options.url + urltype + params;
    //超时处理
    if (options.timeout) {
      oS.timer = setTimeout(function() {
        window[callbackName] = null;
        oHead.removeChild(oS);
        options.fail && options.fail({
          message: "网络不畅，请重新尝试"
        });
      }, options.timeout);
    }
  },
  /**
   * 格式化对象为链接字符串形式
   * @param  {[type]} data [description]
   * @param  {[type]} noEncode 是否不需要encode编码 [可选] true为每一项都不需要encode编码
   * @return {[type]}      [description]
   */
  formatParams: function(data, noEncode) {
    var arr = [];
    for (var name in data) {
      var tmpname = name,
        tmpval = data[name];
      if (!noEncode) {
        tmpname = encodeURIComponent(name);
        tmpval = encodeURIComponent(data[name]);
      }
      arr.push(tmpname + "=" + tmpval);
    }
    return arr.join("&");
  },
  /**
   * 解析目标url为json对象
   * @param url
   * @param isDecode 是否需要decode解码 [可选] true为需要decode解码
   * @returns {Object}
   */
  queryToJson: function(url, isDecode) {

    var url = url.split('#')[0],
      query = url.substr(url.indexOf('?') + 1),
      params, len,
      result = {},
      i = 0,
      key,
      value,
      item,
      param;

    query = !!isDecode ? decodeURIComponent(query) : query;
    params = query.split('&');
    len = params.length;

    for (; i < len; i++) {
      param = params[i].split('=');
      key = param[0];
      if (key) {
        if (param[1]) {
          value = param[1];
        } else {
          value = "";
        }
      }
      item = result[key];
      if ('undefined' == typeof item) {
        result[key] = value;
      } else if (item instanceof Array) {
        item.push(value);
      } else {
        result[key] = [item, value];
      }
    }
    return result;
  },
  /**
   * 获取url参数
   * @param {String} name - 参数名
   * @param {String} url - url地址
   * @param {String} isDecode - 是否需要decode解码 [可选] true为需要decode解码
   * @returns {*}
   */
  getParam: function(name, url, isDecode) {
    var _url = url || window.location.search || window.location.href || '';
    var json = this.queryToJson(_url, isDecode);
    if (name) {
      return json[name] || "";
    } else {
      return json;
    }
  },
  /**
   * 更新url参数，用data对象的参数更新链接上相应的参数
   * @param {obejct} name - 对象
   * @param {String} url - url地址
   * @param {String} isDecode - 是否需要decode解码 [可选] true为需要decode解码
   * @returns {*}
   */
  replaceParam: function(data, url, isDecode) {
    var _url = url || window.location.href,
      json = this.queryToJson(_url, isDecode),
      len = _url.length,
      hash = '',
      origin = _url.split('?')[0],
      paramarr = [],
      params, name, value, url;
    for (var i in data) {
      name = i;
      value = data[name];
      if (name !== '' && value !== '') {
        //替换参数或新增添加参数
        json[name] = value;
      } else if (name !== '' && value === '' && json[name] !== '') {
        // 删除参数
        delete json[name];
      }
    }
    //获取hash值
    if (_url.indexOf('#') > -1) {
      hash = _url.substring(_url.indexOf('#') + 1, len);
    }
    for (var j in json) {
      if (json.hasOwnProperty(j)) {
        paramarr.push(j + '=' + json[j]);
      }
    }
    params = paramarr.join('&');
    url = origin + "?" + params + hash;
    return url;
  },
  /**
   * base64 相关方法
   * @type {Object}
   */
  base64: {
    _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
    /**
     * base64 解码
     * @param  {[type]} input [description]
     * @return {[type]}       [description]
     */
    decode: function(input) {
      var that = this;
      var output = "";
      var chr1, chr2, chr3;
      var enc1, enc2, enc3, enc4;
      var i = 0;
      input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
      while (i < input.length) {
        enc1 = that._keyStr.indexOf(input.charAt(i++));
        enc2 = that._keyStr.indexOf(input.charAt(i++));
        enc3 = that._keyStr.indexOf(input.charAt(i++));
        enc4 = that._keyStr.indexOf(input.charAt(i++));
        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;
        output = output + String.fromCharCode(chr1);
        if (enc3 != 64) {
          output = output + String.fromCharCode(chr2);
        }
        if (enc4 != 64) {
          output = output + String.fromCharCode(chr3);
        }
      }
      output = that._utf8_decode(output);
      return output;
    },
    _utf8_decode: function(utftext) {
      var string = "";
      var i = 0;
      var c = 0;
      var c1 = 0;
      var c2 = 0;
      while (i < utftext.length) {
        c = utftext.charCodeAt(i);
        if (c < 128) {
          string += String.fromCharCode(c);
          i++;
        } else if ((c > 191) && (c < 224)) {
          c2 = utftext.charCodeAt(i + 1);
          string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
          i += 2;
        } else {
          c2 = utftext.charCodeAt(i + 1);
          c3 = utftext.charCodeAt(i + 2);
          string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
          i += 3;
        }
      }
      return string;
    },
    /**
     * base64 编码
     * @param  {[type]} str [description]
     * @return {[type]}       [description]
     */
    encode: function(str) {
      var that = this;
      var out, i, len;　　
      var c1, c2, c3;　　
      len = str.length;　　
      i = 0;　　
      out = "";

      　　
      while (i < len) {
        c1 = str.charCodeAt(i++) & 0xff;
        if (i == len) {　　
          out += that._keyStr.charAt(c1 >> 2);　　
          out += that._keyStr.charAt((c1 & 0x3) << 4);　　
          out += "==";　　
          break;
        }
        c2 = str.charCodeAt(i++);
        if (i == len) {　　
          out += that._keyStr.charAt(c1 >> 2);　　
          out += that._keyStr.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));　　
          out += that._keyStr.charAt((c2 & 0xF) << 2);　　
          out += "=";　　
          break;
        }
        c3 = str.charCodeAt(i++);
        out += that._keyStr.charAt(c1 >> 2);
        out += that._keyStr.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));
        out += that._keyStr.charAt(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6));
        out += that._keyStr.charAt(c3 & 0x3F);　　
      }　　
      return out;
    }
  },
  /**
   * 浅拷贝，将obj2合并到obj1
   * @return {[type]} [description]
   */
  extend: function(obj1, obj2) {
    var that = this,
      obj3 = obj1;
    if (typeof(obj1) != 'object' || typeof(obj2) != 'object' || obj1 == null || obj2 == null) {
      return obj3;
    }
    for (var i in obj3) {
      if (obj2[i]) {
        obj3[i] = obj2[i];
      }
    }
    return obj3;
  },
  mergeJSON: function(minor, main) {
    for (var key in minor) {

      if (main[key] === undefined) { // 不冲突的，直接赋值
        main[key] = minor[key];
        continue;
      }

      // 冲突了，如果是Object，看看有么有不冲突的属性
      // 不是Object 则以main为主，忽略即可。故不需要else
      if (SQFUNC.isJSON(minor[key])) {
        // arguments.callee 递归调用，并且与函数名解耦
        arguments.callee(minor[key], main[key]);
      }
    }
  },
  // 附上工具
  isJSON: function(target) {
    return typeof target == "object" && target.constructor == Object;
  }
};
/**
 * 发行平台jssdk的继承对象，依赖sdkUtil.js
 * @version v2.0
 * @author hlb
 * @description 本文件将压缩进每个发行平台文件，为避免一些研发还没加载完公共文件就开始执行发行jssdk方法
 * 增加一个新的发行平台方法：
 * 1、在SQCOMMON.prototype增加一个新的初始化方法
 * 2、待执行的方法集合that.fns增加新的对象属性
 */
var SQCOMMON = function() {

  var that = this,
    cfn = window.SQFUNC, //公共方法对象
    url = document.URL || ''; //原始链接，原始链接会302跳到研发链接

  that.sdk = ''; //定义初始化平台js-sdk的对象
  that.fns = { //待执行的方法集合
    _serverlog: '',
    _createlog: '',
    _log: '',
    _levellog: '',
    share: '',
    subscribe: '',
    refresh: '',
    pay: '',
    download_wd: '',
    verify: ''
  };
  that.configShare = { //定义初始化平台分享内容的对象
    text: '',
    title: '',
    img: '',
    sucfn: null,
    failfn: null
  };
  that.fnsCallback = { //缓存sdk的回调函数
    download_wd: null,
    subscribe: null,
    verify: null
  };

  //获取后端传的参数，后端将自定义参数放到app_ext参数内，平台对接所需的参数由后端放在app_ext参数内传递
  that.appext = cfn.getParam('app_ext', url); //有些旧平台需将此参数在充值的时候传给后端
  //专题所需参数，传递链接上面的参数不变，活动后端需要根据链接参数加密对比sign验证
  that.ztdata = cfn.queryToJson(url);
  //进游戏传参
  that.userdata = cfn.queryToJson(url);
  //服信息
  that.serverdata = {};
  //初始化一些必要的参数
  if (!that.userdata.app_domain) {
    that.userdata.app_domain = '37.com';
  }
  //解析与格式化app_ext的对象
  that.ext = {};
  if (that.appext) {
    try {
      that.ext = JSON.parse(SQFUNC.base64.decode(decodeURIComponent(that.appext)));
    } catch (e) {
      console.log('链接传的appext为空或加密方法错误');
    }
  }

};
SQCOMMON.prototype = {
  /**
   * 用户上报信息方法
   * @param {Object} data 收集的对象数据
   * @param {String} type 上报数据的类型 默认entergame；server-进入选服页；create-创角；entergame-进入游戏；levelup-角色升级
   * @return {[type]} [description]
   */
  log: function(data, type) {
    var that = this;
    //兼容1.8版本以上的对接文档处理
    if (data.roles && data.roles[0]) {
      data.gender = data.gender || data.roles[0].gender;
      data.profession = data.profession || data.roles[0].profession;
      data.professionid = data.professionid || data.roles[0].professionid;
      data.rolelevel = data.rolelevel || data.roles[0].rolelevel;
    }
    if (!data.party && data.country) {
      data.party = data.country;
    }
    //兼容1.8版本以下的对接文档处理
    if (!data.roles && data.profession) {
      //多角色数组
      data.roles = [{ profession: data.profession || '', professionid: data.professionid || '', rolelevel: data.rolelevel || '', gender: (data.gender == 1) ? 'boy' : 'girl' }]
    }

    /**
     * 进入游戏，除了执行平台的自定义方法，还要初始化活动
     * @return {[type]} [description]
     */
    function enterGame(_data) {
      that.serverdata = _data;
      //将sid添加到全局变量
      that.ztdata.sid = _data.serverid;
      that.userdata.sid = _data.serverid;
      that._zt();
    }
    /**
     * 更新等级和其他信息
     * @param  {[type]} _data [description]
     * @return {[type]}       [description]
     */
    function levelUpdate(_data) {
      that.serverdata = _data;
    }
    switch (type) {
      case 'server':
        {
          that.serverdata = data;
          that._serverlog(data);
          break;
        }
      case 'create':
        {
          that.serverdata = data;
          that._createlog(data);
          break;
        }
      case 'entergame':
        {
          enterGame(data);
          that._log(data);
          break;
        }
      case 'levelup':
        {
          levelUpdate(data);
          that._levellog(data);
          break;
        }
      case 'precreate':
        {
          that._precreatelog(data);
          break;
        }
      default:
        {
          enterGame(data);
          that._log(data); //兼容1.3版本以下的文档
        }
    }
  },
  /**
   * 专题
   * @param {number} type 2-不需要显示icon 1-需要显示icon
   * @return {[type]} [description]
   */
  _zt: function(type) {
    var that = this;
    if (typeof SQZT == "undefined") {
      SQFUNC.loadScript('https://ptresh5.' + that.userdata.app_domain + '/common/zt.js?t=' + new Date().getTime(), function() {
        var ZT = new SQZT(that.ztdata, that.userdata.app_domain);
      });
    }
  },
  /**
   * 进入选服页——数据上报——信息收集
   * @param {Object} data 收集的对象数据
   * @return {[type]} [description]
   */
  _serverlog: function(data) {},
  /**
   * 创角——数据上报——信息收集
   * @param {Object} data 收集的对象数据
   * @return {[type]} [description]
   */
  _createlog: function(data) {},
  /**
   * 进入游戏——数据上报——信息收集
   * @param {Object} data 收集的对象数据
   * @return {[type]} [description]
   */
  _log: function(data) {},
  /**
   * 角色升级——数据上报——信息收集
   * @param {Object} data 收集的对象数据
   * @return {[type]} [description]
   */
  _levellog: function(data) {},
  _precreatelog: function(data) {},
  /**
   * 分享功能
   * @return {function} share
   */
  share: function(text, title, img, sucfn, failfn) {},
  /**
   * 关注功能
   * @return {function} subscribe
   */
  subscribe: function() {},
  /**
   * 下载微端的方法
   * @param  {Function} callback [description]
   * @return {[type]}            [description]
   */
  download_wd: function(callback) {},
  /**
   * 支付功能
   */
  pay: function(data) {
    var that = this;
    if (that.sdk) {
      that.payCall(data);
    } else {
      that.fns.pay = 'that.pay(' + JSON.stringify(data) + ')';
    }
  },
  /**
   * 获取对接平台的支付参数并执行平台的充值方法
   * @return {[type]} [description]
   */
  payCall: function(data, successfn, failfn, netdownfn) {
    var that = this;
    SQFUNC.ajax({
      url: "https://apipayh5." + that.userdata.app_domain + "/index.php?c=order&a=create_order",
      type: "POST",
      data: data,
      dataType: "json",
      success: function(res, xml) {
        try {
          var res = JSON.parse(res);
          if (res && +res.code === 1 && res.data) {
            var pdata = res.data.pay_data;
            if (successfn && typeof(successfn) == 'function') {
              successfn(pdata);
            }
          } else {
            if (failfn && typeof(failfn) == 'function') {
              failfn(res);
            } else {
              alert(res.msg);
            }
          }
        } catch (e) {
          alert(e);
        }
      },
      error: function(status) {
        if (netdownfn && typeof(netdownfn) == 'function') {
          netdownfn();
        } else {
          alert('网络不畅，请稍后再试');
        }
      }
    });
  },
  /**
   * 刷新页面
   * @return {[type]} [description]
   */
  refresh: function() {
    window.location.reload();
  },
  /**
   * 实名认证
   * @return {[type]} [description]
   */
  verify: function(callback) {

  },
  /**
   * 切换帐号
   * @return {[type]} [description]
   */
  switchAccount: function() {

  },
  /**
   * 保存到桌面
   * @return {[type]} [description]
   */
  saveToDesktop: function() {

  },
  bindPhone: function(sucfn, failfn) {}
};
import PaySDK from './paysdk';
import sdk from 'sdk_wxa';

function getRandomImg() {
  var imgArr = [{
    url: 'https://res1.cqjy.5jli.com/cqjy_res_minigame_tishen/resources/ui/images/yunying/1-201907241106.jpg',
    desc: '每日免费领VIP！这传奇爽爆了！'
  }, {
    url: 'https://res1.cqjy.5jli.com/cqjy_res_minigame_tishen/resources/ui/images/yunying/2-201907241106.jpg',
    desc: '超变宠物版传奇！上线再送vip！'
  }, {
    url: 'https://res1.cqjy.5jli.com/cqjy_res_minigame_tishen/resources/ui/images/yunying/3-201907241106.jpg',
    desc: '百倍爆率一键回收，福利服来了！'
  }]
  var randomIndex = Math.floor(Math.random() * imgArr.length)
  return imgArr[randomIndex]
}

(function() {
  var SQGAMESDK = function() {
    window.SDK = new sdk({
      gameid: 573, //必填字段，传入游戏ID
      appid: 'wx166cd5237ad71a6b', //小游戏的appid
    })
    window.myobj = {};
    wx.onShow((options) => {
      SDK.updateBelong(options);
      myobj.MPDATA = SDK.getShareParams(options) || {}
      myobj.MPDATA.fuid = myobj.MPDATA.fuid || options.query.fuid;
      myobj.MPDATA.chid = myobj.MPDATA.chid || options.query.chid;
      myobj.MPDATA.subchid = myobj.MPDATA.subchid || options.query.subchid;
    })
  };
  SQGAMESDK.prototype = new SQCOMMON();
  SQGAMESDK.prototype.login = function(cb) {
    SDK.login({}, function(data) {
      if (data.error) console.log(data.error);
      else {
        //登录成功，回调的data如下
        data.is_mypro = (wx.getLaunchOptionsSync().scene == 1103 || wx.getLaunchOptionsSync().scene == 1104) ? true : false
        wx.request({
          url: 'https://apigameh5.37.com/enter/awyxcx/23?a=quickAppEnter',
          data: data,
          success: function(res) {
            var data = res.data.data;
            myobj.app_ext = data.app_ext;
            myobj.uid = data.uid;

            //初始化右上角分享
            var p_chid = myobj.MPDATA.chid ? ('&chid=' + myobj.MPDATA.chid) : (
              JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.chid ? ('&chid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.chid) : ''
            )
            var p_subchid = myobj.MPDATA.subchid ? ('&subchid=' + myobj.MPDATA.subchid) : (
              JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.subchid ? ('&subchid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.subchid) : ''
            )
            var params = p_chid + p_subchid

            var shareObj = getRandomImg()
            wx.onShareAppMessage(() => ({
              title: shareObj.desc,
              query: 'fuid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).openId + params,
              imageUrl: shareObj.url
            }))
            wx.showShareMenu({})

            //MP统计
            wx.request({
              url: 'https://apigameh5.37.com/index.php?c=api&a=default&cc=Api&ca=stat_share&appid=awyxcx&game_id=23',
              data: {
                app_ext: myobj.app_ext,
                newuser: myobj.newuser ? myobj.newuser : 0,
                chid: myobj.MPDATA.chid,
                device: wx.getSystemInfoSync().platform == ('android') ? 1 : 2,
                subchid: myobj.MPDATA.subchid,
                fuid: myobj.MPDATA.fuid,
              },
              success: function(json) {},
              fail: function(status) {}
            });
            SDK.setMPAliveStat()

            cb({
              code: 1,
              data: data
            })
          },
          fail: function(res) {
            cb({
              code: 0
            })
          }
        })
      }
    })
  }
  SQGAMESDK.prototype.pay = function(data) {
    var that = this;
    data.app_ext = myobj.app_ext;
    data.cp_servername = that.serverdata.servername;
    data.cp_rolename = that.serverdata.rolename;
    data.cp_roleid = that.serverdata.roleid;
    data.cp_rolelevel = that.serverdata.rolelevel;
    data.cp_viplevel = that.serverdata.viplevel;
    wx.request({
      url: "https://apipayh5.37.com/index.php?c=order&a=create_order",
      data: data,
      success: function(res) {
        var data = res.data.data.pay_data;
        PaySDK.pay(data, function(error, errmsg, transId) {

          // error 错误码 0 表示支付成功 其他表示支付失败 
          // errmsg 错误提示 错误码的详细提示
          // transId 如果error = 0时返回，本次支付的订单id

          // console打印记录示例
          console.log('PaySDK', error, errmsg);

          // 界面中展示结果示例
          if (error) {
            wx.showModal({
              title: '支付结果',
              content: '支付失败：' + errmsg,
              showCancel: false,
            });
          } else {
            wx.showModal({
              title: '支付结果',
              content: '支付成功',
              showCancel: false,
            });
          }
        });
      },
      fail: function(status) {}
    });
  };
  SQGAMESDK.prototype.all = function(type, params, cb) {
    switch (type) {
      case 'awy_getAd':
        {
          SDK.getRandAd({}, (res) => {

            //此方法需传入一个空对象

            if (res) {

              //当前存在广告，项目中需要显示广告
              //res为一个数组

              res = res[0]

              if (res.type == 1) {
                //当前广告只有一张图片，利用2.8相关方法创建对象并绘制到项目中即可（默认抖动特效）
                let iconurl = res.data.icon //广告icon路径
                let appid = res.data.appid //当前广告的appid , 调用navigateToMiniProgram方法时会用到
                let type = res.data.type //当前广告类别, 调用navigateToMiniProgram方法时会用到

              } else if (res.type == 2) {
                //当前广告是一个图片列表,需要项目创建帧动画并添加到项目中,可参考2.8相关代码段（帧动画效果）
                let iconlist = res.data.icon //图片列表 Array
                let interval = res.data.intervals //每帧间隔 (毫秒)
                let appid = res.data.appid //当前广告的appid , 调用navigateToMiniProgram方法时会用到
                let type = res.data.type //当前广告类别 , 调用navigateToMiniProgram方法时会用到

              }
              cb({
                code: 1,
                data: {
                  res: res
                }
              })
            } else {
              cb({
                  code: 0
                })
                //res = undefined
                //没有广告数据，无需显示广告
            }
          })
          break;
        }
      case 'awy_clickAd':
        {
          SDK.navigateToMiniProgram({
            appid: params.data.appid, //必填字段，此appid从广告的data里面获取,
            type: params.data.type //必填字段, 此type从广告的data里面获取，不能传错，将会影响跳转以及数据统计
          }, (res) => {

            if (res) { //此时收到了下一组广告数据
              res = res[0]

              if (res.type == 1) {

                //当前广告只有一张图片，利用 2.2 相关方法创建对象并绘制到项目中即可（默认抖动特效）
                let iconurl = res.data.icon //广告icon路径
                let appid = res.data.appid //当前广告的appid
                let type = res.data.type //广告类型

              } else if (res.type == 2) {

                //当前广告是一个图片列表,需要项目创建帧动画并添加到项目中,可参考 2.2 相关代码段（帧动画效果）
                let iconlist = res.data.icon //图片列表
                let interval = res.data.intervals //每帧间隔 (毫秒)
                let appid = res.data.appid //当前广告的appid
                let type = res.data.type //广告类型

              }

            } else {

              //res = undefined
              // 没有广告存在，可移除项目中相关广告组件

            }

          })
          break;
        }
      case 'awy_clickKf':
        {
          wx.openCustomerServiceConversation({
            showMessageCard: true,
            sendMessageTitle: '斩月屠龙',
            sendMessageImg: params.sendMessageImg ? params.sendMessageImg : 'https://res1.cqjy.5jli.com/cqjy_res_minigame_ts/resources/ui/images/yunying/service_interaction.jpg?201901151543',
            sendMessagePath: 'index.html?kfflag=1',
            success: res => {
              console.log(res);
              if (res.query && res.query.kfflag == 1) {
                cb && typeof cb == 'function' && cb({
                  code: 1
                })
              }
            },
            fail: res => { console.log(res) },
            complete: res => { console.log(res) }
          })
          break;
        }
      default:
        {
          break;
        }
    }
  }
  SQGAMESDK.prototype.wx_share = function(sucfn, failfn, cp_share_type) {
    var p_chid = myobj.MPDATA.chid ? ('&chid=' + myobj.MPDATA.chid) : (
      JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.chid ? ('&chid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.chid) : ''
    )
    var p_subchid = myobj.MPDATA.subchid ? ('&subchid=' + myobj.MPDATA.subchid) : (
      JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.subchid ? ('&subchid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.subchid) : ''
    )
    var params = p_chid + p_subchid
    var shareObj = getRandomImg()
    wx.shareAppMessage({
      title: shareObj.desc,
      imageUrl: shareObj.url,
      query: 'fuid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).openId + params + '&cp_sid=' + myobj.sid + '&cp_fuid=' + myobj.uid + '&cp_share_type=' + cp_share_type
    });
    SDK.setMPShareStat()
    sucfn(cp_share_type)
  }
  SQGAMESDK.prototype.cp_share = function(sucfn, failfn) {
    var p_chid = myobj.MPDATA.chid ? ('&chid=' + myobj.MPDATA.chid) : (
      JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.chid ? ('&chid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.chid) : ''
    )
    var p_subchid = myobj.MPDATA.subchid ? ('&subchid=' + myobj.MPDATA.subchid) : (
      JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.subchid ? ('&subchid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).query.subchid) : ''
    )
    var params = p_chid + p_subchid
    var shareObj = getRandomImg()
    wx.shareAppMessage({
      title: shareObj.desc,
      imageUrl: shareObj.url,
      query: 'fuid=' + JSON.parse(SQFUNC.base64.decode(decodeURIComponent(myobj.app_ext))).openId + params + '&cp_sid=' + myobj.sid + '&cp_fuid=' + myobj.uid
    });
    sucfn()
  }
  SQGAMESDK.prototype._createlog = function(data) {
    var that = this;
    data.app_ext = myobj.app_ext;
    data.game_id = 23;
    myobj.newuser = 1
    wx.request({
      url: 'https://apigameh5.37.com/index.php?c=api&a=default&cc=Api&ca=createRoleInfo&appid=awyxcx',
      data: data,
      success: function(json) {},
      fail: function(status) {}
    });
  };
  SQGAMESDK.prototype._log = function(data) {
    var that = this;
    myobj.sid = data.serverid;
  };
  SQGAMESDK.prototype._levellog = function(data) {
    var that = this;
    data.app_ext = myobj.app_ext;
    data.game_id = 23;
    wx.request({
      url: 'https://apigameh5.37.com/index.php?c=api&a=default&cc=Api&ca=levelReport&appid=awyxcx&game_id=23',
      data: data,
      success: function(json) {},
      fail: function(status) {}
    });
  };
  window.SQGAMESDK = SQGAMESDK;
})();