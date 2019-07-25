(function() {
    function _createUUID() {
        let d = new Date().getTime();
        let uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            let r = (d + Math.random() * 16) % 16 | 0;
            d = Math.floor(d / 16);
            return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
        });
        return uuid;
    }

    //platform stat
    function _stat(args = {}) {
        let item, type = args.type;
        switch (type) {
            case 0:
                item = 'wxa_float_ad';
                break;
            case 1:
                item = 'wxa_recommend_ad';
                break;
            case 2:
                item = 'wxa_guess_ad';
                break;
            case 3:
                item = 'wxa_wall_ad';
                break;
        }
        if (args.item) {
            item = args.item;
        }
        if (args.ad) {
            args.subitem.push({
                stat: this.device == 'iOS' ? 'device_1' : 'device_0'
            }, {
                stat: `mode_${type}`
            }, {
                stat: `gameid_${this.gameid}`
            })

            if (args.data) {
                args.subitem.push({
                    stat: `id_${args.data.id}`
                })
            }
        }
        let data = {
            cmd: 'combineStat',
            uid: this.uid,
            item: item,
            subItem: JSON.stringify(args.subitem),
            v: Date.now()
        }
        if (args.click) {
            data.gameid = this.gameid
        }
        wx.request({
            url: `${this.baseurl}comstat/stat`,
            data: data,
            method: 'POST',
            complete: (e) => {
                console.log('stat', data, e.data)
            }
        })
    }

    function _replace(url) {
        return this.domain == '11h5.com' ? url : url.replace(/11h5.com/g, this.domain)
    }

    function _adHandle(data, type = 0) {
        data.iconurl = _replace.call(this, data.iconurl);
        data.imgurl = _replace.call(this, data.imgurl);
        let icon = data.iconurl.split('|'),
            _data = {
                type: 1,
                data: {
                    appid: data.appid,
                    title: data.title,
                    icon: icon[0],
                    type: type
                }
            };
        if (icon.length > 1) {
            _data.type = 2;
            _data.data.icon = icon;
            _data.data.intervals = data.intervals || 150;
        }
        if (type == 3) {
            _data.data.gameid = data.adgameid;
            _data.data.slogan = data.slogan;
            _data.data.quantity = data.awardCnt;
            _data.data.cate = data.awardType;
            _data.data.access = 0;
            _data.data.hasgot = 0;
            _data.data.isReady = 0;
        }
        return _data;
    }

    function _getConfig(callback) {
        if (Object.keys(this.config).length) {
            return callback && callback();
        }
        wx.request({
            url: `${this.configurl}wxa_config.json`,
            data: {
                v: Date.now()
            },
            complete: (res) => {
                if (res && res.data) {
                    this.config = res.data;
                }
                callback && callback();
            }
        })
    }

    function _paramsHandle(chid, subchid, channel) {
        let query = {
            chid: chid,
            subchid: subchid
        };
        if (this.uid && this.uid != 1000) {
            query.suid = this.uid
        }
        if (channel) {
            let extra = channel.split('|');
            for (let i = 0; i < extra.length; i++) {
                let _extra = extra[i].split('=');
                query[_extra[0]] = _extra[1]
            }
        }
        return query
    }

    function _previewImage(data = {}, type) {
        if (data.imgurl) {
            if (type == 3) { //积分墙
                _setGameWallStatus.call(this, data);
            }
            if (this.appid) {
                let pos;
                if (data.position != undefined && data.position != '') {
                    pos = JSON.parse(data.position);
                }
                if (data.type == 1) { //自研游戏

                    if (type == 0) {
                        pos = pos[0]
                    } else {
                        if (pos[1]) {
                            pos = pos[1]
                        } else {
                            pos = pos[0]
                        }
                    }

                    let channel = data.outChannel,
                        chid = data.chid,
                        params = {},
                        subchid = data.subchid;

                    subchid += this.device == 'iOS' ? 1 : 0;
                    subchid += `_${type}`;

                    params = _paramsHandle.call(this, chid, subchid, channel);

                    let key = `${data.id}_${this.device}_${type}`;
                    let image = wx.getStorageSync(key);
                    let url = wx.getStorageSync((data.id).toString());
                    if (image && url == data.imgurl) {
                        wx.previewImage({
                            urls: [image],
                        })
                    } else {
                        _cParams.call(this, params, (res) => {
                            if (res && res.c) {
                                this.showShareImg({
                                    x: pos.x,
                                    y: pos.y,
                                    key: key,
                                    bgImg: data.imgurl,
                                    spaceWidth: pos.width,
                                    appid: data.appid,
                                    query: `cp_adStat:${res.c}`
                                })
                                wx.setStorageSync(`${data.id}`, data.imgurl);
                            } else {
                                console.log('参数压缩失败');
                                wx.previewImage({
                                    urls: [data.imgurl],
                                })
                            }
                        })
                    }
                } else {
                    wx.previewImage({
                        urls: [data.imgurl],
                    });
                }
            } else {
                wx.previewImage({
                    urls: [data.imgurl],
                });
            }
        } else {
            wx.showModal({
                title: '错误提示',
                content: `小程序码图片链接为空，请检查 navigateToMiniProgram 方法中传入的type是否正确 `,
                showCancel: false
            })
        }
    }

    function _refreshAd(type, callback) {
        let cfg = this.config;
        if (type == 1) {
            this.getRandAd({}, (res) => {
                callback(res)
            })
        }
        if (cfg.autoChangeAd) {
            if (!type) {
                clearTimeout(this.changeAlone);
                this.changeAlone = setTimeout(() => {
                    this.getRandAd({}, (res) => {
                        callback(res)
                    })
                }, cfg.autoChangeInterval)
            }
            if (type == 2) {
                clearTimeout(this.changeGuess);
                this.changeGuess = setTimeout(() => {
                    this.getRandAd({
                        type: type
                    }, (res) => {
                        callback(res)
                    })
                }, cfg.autoChangeInterval)
            }
        }
    }

    function _setGameWallStatus(data) {
        wx.request({
            url: `${this.pointurl}setPlayerWallInfo`,
            data: {
                token: this.token,
                channel: this.gameid,
                gameid: data ? data.adgameid : 0,
                stopid: 1,
                v: Date.now()
            },
            complete: (res) => {
                if (res && res.data && res.data.error) {
                    wx.showModal({
                        title: '错误提示',
                        content: `积分墙设置错误--${res.data.error}`,
                        showCancel: false
                    })
                }
                try {
                    if (data) {
                        if (!wx.getStorageSync('walltime') && !data.isReady) {
                            wx.setStorageSync('walltime', `${Date.parse(new Date()) / 1000}_${data.title}`)
                        }
                    }
                } catch (e) {}
            }
        })
    }

    function _cParams(args, callback) {
        let params = {
            cmd: 'cParam'
        }
        for (let i in args) {
            params[i] = args[i]
        }
        wx.request({
            url: `${this.mpurl}`,
            data: params,
            complete: (res) => {
                console.log('cparams', res);
                if (res && res.data) {
                    res = res.data;
                    if (res.error == 0) {
                        callback && callback({
                            c: res.C
                        })
                    } else {
                        callback && callback();
                    }
                } else {
                    callback && callback();
                }
            }
        })
    }

    function _optionsSplit(params = {}, options = null) {
        if (!options) {
            options = wx.getLaunchOptionsSync()
        }
        let query = options.query,
            scene = query.scene;
        for (let i in query) {
            if (query[i] != undefined) {
                if (i == 'scene') {
                    scene = decodeURIComponent(scene).split(',');
                    if (scene.length) {
                        for (let k = 0; k < scene.length; k++) {
                            let _scene = scene[k].split(':');
                            params[_scene[0]] = _scene[1];
                        }
                    }
                } else {
                    let keys = ['appid', 'gameid'];
                    if (keys.indexOf(i) == -1) {
                        params[i] = query[i]
                    }
                }
            }
        }
        return {
            options: options,
            params: params
        };
    }

    class Sdk {
        version = '0.1.1';
        domain = '11h5.com';
        attempt = 0;
        config = {};
        newOptions = null;

        constructor(opt = {}) {

            for (let i in opt) {
                this[i] = opt[i]
            }

            this.baseurl = `https://adapi.${this.domain}/`
            this.configurl = `https://act.${this.domain}/adResource/`
            this.qrcodeurl = `https://api.${this.domain}/common?cmd=getwxacodeunlimit`
            this.mpurl = `https://adstat.${this.domain}/stat/`
            this.loginurl = `https://wxlogin.${this.domain}/`
            this.pointurl = this.wallTest ? 'http://dev6.11h5.com:3062/wall/?cmd=' : `https://newintegral-wall.${this.domain}/wall?cmd=`

            try {
                let systemInfo = wx.getSystemInfoSync();
                this.device = systemInfo.system.indexOf('iOS') != -1 ? 'iOS' : 'Android';
                this.screenWidth = systemInfo.screenWidth;
                this.screenHeight = systemInfo.screenHeight;
            } catch (e) {}

            if (!this.gameid) {
                throw new Error('params: invalid gameid')
            }

            if (!this.uid) {
                try {
                    this.uid = wx.getStorageSync('yg_uid') || _createUUID()
                    wx.setStorageSync('yg_uid', this.uid);
                } catch (e) {
                    this.uid = 1000
                }
            }
        }

        showShareImg(args = {
            x: 375,
            y: 1080,
            spaceWidth: 320
        }) {
            let key = args.key || 'shareImg';
            try {
                let image = wx.getStorageSync(key)
                if (image) {
                    return wx.previewImage({
                        urls: [image],
                    })
                }
            } catch (e) {}
            wx.showLoading({
                title: '加载中',
            })

            console.log(this.screenWidth, this.screenHeight);

            let canvas = wx.createCanvas(),
                ctx = canvas.getContext('2d'),
                bg = wx.createImage(),
                scale = this.screenWidth / 750,
                dw = this.screenWidth,
                center = {
                    x: parseInt(args.x * scale),
                    y: parseInt(args.y * scale)
                },
                spaceWidth = parseInt(args.spaceWidth * scale),
                half = spaceWidth / 2;
            if (this.screenWidth > this.screenHeight) {
                scale = this.screenHeight / 750;
                center = {
                    x: parseInt(args.x * scale),
                    y: parseInt(args.y * scale)
                };
                spaceWidth = parseInt(args.spaceWidth * scale);
                half = spaceWidth / 2;
                canvas.width = 750 * scale;
                canvas.height = 1334 * scale;
                dw = this.screenHeight;
            }
            bg.src = args.bgImg;
            bg.onerror = () => {
                console.log('大图加载出错，背景地址---->', args.bgImg)
            }
            bg.onload = () => {
                ctx.drawImage(bg, 0, 0, dw, scale * 1334);
                ctx.save();
                ctx.arc(center.x, center.y, half, 0, 2 * Math.PI);
                ctx.clip();
                console.log('小程序码参数', args.query)
                let params = JSON.stringify({
                    scene: args.query,
                    width: 400
                });
                wx.downloadFile({
                    url: `${this.qrcodeurl}&appid=${args.appid}&param=${params}`,
                    complete: (res) => {
                        wx.hideLoading();
                        let qrcode = wx.createImage();
                        qrcode.src = res.tempFilePath;
                        qrcode.onload = () => {
                            ctx.drawImage(qrcode, center.x - half, center.y - half, spaceWidth, spaceWidth)
                            let image = canvas.toDataURL('image/jpeg', .7);
                            wx.previewImage({
                                urls: [image],
                                success: () => {
                                    wx.setStorageSync(key, image);
                                }
                            })
                        }
                    }
                })
            }
        }

        getShareParams(options = null) {
            let args = _optionsSplit({}, options || this.newOptions)['params'];
            args.suid = this.uid;
            return args;
        }

        setMPAliveStat() {
            if (this.token) {
                clearTimeout(this.mpAliveStat);
                let _this = this;

                function _alive() {
                    wx.request({
                        url: `${_this.mpurl}`,
                        data: {
                            cmd: 'alive',
                            token: _this.token
                        },
						complete: (res) => {
							_this.mpAliveStat = setTimeout(() => {
								_alive();
							}, 5000)
						//	console.log('mpAliveStat=====>', res)
						}
                    })
                }
                _alive();
            } else {
                console.log('token不存在')
            }
        }

        setMPShareStat() {
            if (this.token) {
                wx.request({
                    url: `${this.mpurl}`,
                    data: {
                        cmd: 'share',
                        token: this.token
                    },
                    complete: (res) => {
                        console.log('mpShareStat===>', res)
                    }
                })
            } else {
                console.log('token不存在')
            }
        }

        setShareStat(params = {}) {
            let args = {
                item: 'wxa_share_stat'
            }
            if (params.key) {
                args.subitem = [{
                    ad: params.key
                }, {
                    stat: `gameid_${this.gameid}`
                }, {
                    stat: `shareid_${params.shareId}`
                }]
                _stat.call(this, args)
            }
        }

        getShareInfo(params = {}, callback) {
            // params = {type: type, id: id}  optional
            params.gameid = this.gameid;
            params.v = Date.now();
            wx.request({
                url: `${this.baseurl}share/api?cmd=getRandShare`,
                data: params,
                complete: (res) => {
                    if (res && res.data) {
                        res = res.data.share;
                        this.shareInfo = res;
                        return callback && callback({
                            desc: res.content,
                            imgurl: _replace.call(this, res.imgurl),
                            id: res.id
                        })
                    }
                    callback && callback();
                }
            })
        }

        clearAutoEvent() {
            clearTimeout(this.changeAlone)
            clearTimeout(this.changeGuess)
        }

        checkAdModeStatus(callback) {
            let status = {
                hasGameWall: false,
                hasRecommend: false
            };
            this.getGameWallList((res) => {
                if (res) {
                    status.hasGameWall = true;
                    status.gameWallData = res;
                }
                this.getRandAd({
                    type: 1
                }, (res) => {
                    if (res) {
                        status.hasRecommend = true;
                        status.recommendData = res;
                    }
                    callback && callback(status)
                })
            })
        }

        checkWallTip(callback) {
            try {
                let walltime = wx.getStorageSync('walltime');
                if (walltime) {
                    walltime = walltime.split('_');
                    wx.removeStorageSync('walltime');
                    if (Date.parse(new Date()) / 1000 - parseInt(walltime[0]) < 60) {
                        wx.showModal({
                            title: '提醒',
                            content: `您在[${walltime[1]}]中体验未满1分钟，继续即可领取奖励！`,
                            showCancel: false,
                            confirmText: '知道了'
                        })
                        _setGameWallStatus.call(this);
                    } else {
                        return callback && callback({
                            isReady: true
                        })
                    }
                }
                callback && callback({
                    isReady: false
                })
            } catch (e) {}
        }

        //广告跳转
        navigateToMiniProgram(params = {}, callback) {
            let appid = params.appid;
            let type = params.type;
            if (appid) {
                if (typeof type == 'number') {
                    let adInfo;
                    let _args = {
                        ad: true,
                        click: true,
                        type: type
                    }
                    switch (type) {
                        case 0:
                            adInfo = this.alone;
                            break;
                        case 1:
                            adInfo = this.recommend
                            break;
                        case 2:
                            adInfo = this.guess;
                            break;
                        case 3:
                            adInfo = this.gameWall;
                            break;
                    }
                    for (let i = 0; i < adInfo.length; i++) {
                        if (appid == adInfo[i].appid) {
                            adInfo = adInfo[i];
                            break;
                        }
                    }
                    _args.data = adInfo;
                    let channel = adInfo.outChannel,
                        path = '/?',
                        chid = adInfo.chid,
                        subchid = adInfo.subchid;
                    if (chid == 1967) {
                        subchid += `__`
                    }
                    subchid += this.device == 'iOS' ? 1 : 0;
                    if (chid == 1967) {
                        subchid += '__';
                    } else {
                        subchid += '_';
                    }
                    subchid += type;

                    let query = _paramsHandle.call(this, chid, subchid, channel);

                    for (let i in query) {
                        if (query[i]) {
                            path += `${i}=${query[i]}&`
                        }
                    }
                    console.log('path', path);
                    _args.subitem = [{
                        ad: 'click'
                    }];
                    _stat.call(this, _args)
                    if (adInfo.directMode == 1 && wx.navigateToMiniProgram) {
                        wx.navigateToMiniProgram({
                            appId: appid,
                            path: path,
                            complete: (e) => {
                                let ad = 'click_cancel';
                                if (e.errMsg == 'navigateToMiniProgram:ok') {
                                    ad = 'click_ok';
                                    if (type == 3) {
                                        _setGameWallStatus.call(this, adInfo)
                                    }
                                }
                                _args.subitem = [{
                                    ad: ad
                                }];
                                _stat.call(this, _args)
                                if (!type) {
                                    _refreshAd.call(this, 1, (data) => {
                                        callback && callback(data)
                                    })
                                }
                            }
                        })
                    } else {
                        _previewImage.call(this, adInfo, type);
                        if (!type) {
                            _refreshAd.call(this, 1, (data) => {
                                callback && callback(data)
                            })
                        }
                    }
                } else {
                    wx.showModal({
                        title: '参数错误',
                        content: '缺少type参数',
                        showCancel: false
                    })
                }
            }
        }

        //积分墙领奖
        getGameWallAward(gameid, callback) {
            if (!gameid) {
                return wx.showModal({
                    title: '错误提示',
                    content: '领取奖励gameid不能为空'
                })
            }
            wx.request({
                url: `${this.pointurl}getAward`,
                data: {
                    token: this.token,
                    channel: this.gameid,
                    gameid: gameid,
                    v: Date.now()
                },
                complete: (res) => {
                    if (res && res.data) {
                        callback && callback(res.data);
                    }
                }
            })
        }

        //获取积分墙
        getGameWallList(callback) {
            this.getRandAd({
                type: 3
            }, (res) => {
                callback && callback(res);
            })
        }

        //登录
        login(args = {}, callback) {
            wx.login({
                complete: (res) => {
                    if (res && res.code) {
                        let params = {
                                cmd: 'wxaLogin',
                                code: res.code,
                                gameid: this.gameid,
                                appid: this.appid,
                                device: this.device == 'iOS' ? 2 : 1
                            },
                            options = _optionsSplit(params);
                        params = options['params'];
                        for (let i in args) {
                            if (i) {
                                params[i] = args[i]
                            }
                        }
                        console.log('sdk--启动参数', options['options']);
                        console.log('sdk--登录参数', params);

                        if (params.logkey) {
                            wx.request({
                                url: `${this.loginurl}api`,
                                data: {
                                    cmd: 'getTokenByLogKey',
                                    logkey: params.logkey
                                },
                                method: 'POST',
                                complete: (res) => {
                                    if (res && res.data && res.data.token) {
                                        this.uid = res.data.uid;
                                        this.token = res.data.token;
                                        callback && callback({
                                            options: options['options'],
                                            uid: this.uid,
                                            token: this.token
                                        })
                                    } else {
                                        callback && callback({
                                            error: 3
                                        })
                                        //客服登录玩家账号失败
                                    }
                                }
                            })
                        } else {
                            wx.request({
                                url: `${this.loginurl}wxlogin`,
                                data: params,
                                method: 'POST',
                                complete: (res) => {
                                    if (res && res.data && res.data.token) {
                                        this.uid = res.data.uid;
                                        this.token = res.data.token;
                                        console.log('uid=====>', this.uid);
                                        console.log('token=====>', this.token);
                                        callback && callback({
                                            options: options['options'],
                                            uid: this.uid,
                                            token: this.token
                                        })
                                    } else {
                                        this.attempt++;
                                        if (this.attempt <= 2) {
                                            this.login(callback);
                                        } else {
                                            callback && callback({ //获取token失败
                                                error: 2
                                            })
                                        }
                                    }
                                }
                            })
                        }
                    } else {
                        callback && callback({ //获取code失败
                            error: 1
                        })
                    }
                }
            })
        }

        //热启动更新用户归属
        updateBelong(options = null) {
            let params = {
                cmd: 'updateBelong',
                gameid: this.gameid,
                uid: this.uid
            };
            if (options) {
                this.newOptions = options;
            }
            params = _optionsSplit(params, options)['params'];
            if (params.suid || params.cp_adStat) {
                wx.request({
                    url: `${this.mpurl}`,
                    data: params,
                    complete: (res) => {
                        console.log('updateBelong', res.data);
                    }
                })
            }
        }

        //获取广告
        getRandAd(params = {}, callback) {
            _getConfig.call(this, () => {
                let cfg = this.config;
                if (!cfg.showAd) {
                    return callback && callback()
                }
                let type = params.type || 0,
                    args = {
                        cmd: 'getAdsByType',
                        adType: type,
                        gameid: this.gameid,
                        device: this.device == 'iOS' ? 1 : 0,
                        v: Date.now()
                    };
                if (this.alone && !type) {
                    args.lastAdId = this.alone[0].id
                }
                wx.request({
                    url: `${this.baseurl}new_api/`,
                    // url: `http://dev2.vutimes.com:7115/new_api/`,
                    data: args,
                    complete: (res) => {
                        if (res && res.data && res.data.ad) {
                            res = res.data.ad;
                            if ((res instanceof Array) && !res.length || (res instanceof Object) && !Object.keys(res).length) {
                                return callback && callback();
                            }
                            let _args = {
                                ad: true,
                                data: null,
                                subitem: [{
                                    ad: 'show'
                                }]
                            };
                            switch (type) {
                                case 1: //精品推荐
                                    this.recommend = res;
                                    break;
                                case 2: //猜你喜欢
                                    this.guess = res;
                                    break;
                                case 3: //积分墙
                                    this.gameWall = res;
                                    break;
                                default: //浮动广告
                                    res = [res];
                                    this.alone = res;
                                    _args.data = this.alone[0];
                            }
                            _args.type = type;
                            _stat.call(this, _args);
                            if (type != 1 && type != 3) {
                                _refreshAd.call(this, type, (data) => {
                                    callback(data)
                                })
                            }
                            let data = [];
                            for (let i = 0; i < res.length; i++) {
                                data.push(_adHandle.call(this, res[i], type))
                            }
                            if (type == 3) {
                                wx.request({
                                    url: `${this.pointurl}getPlayerWallInfo`,
                                    data: {
                                        token: this.token,
                                        channel: this.gameid
                                    },
                                    complete: (res) => {
                                        if (res && res.data) {
                                            res = res.data;
                                            console.log('积分墙点击态：', res);
                                            console.log('积分墙请求token：', this.token);

                                            let wall = res.WallInfo;
                                            if (wall) {
                                                for (let i = 0; i < data.length; i++) {
                                                    let _data = wall[data[i].data.gameid]
                                                    if (_data) {
                                                        data[i].data.access = _data.access;
                                                        data[i].data.hasgot = _data.hasgot;
                                                        if (Date.parse(new Date()) / 1000 - _data.time > 60) {
                                                            data[i].data.isReady = 1;
                                                        }
                                                    }
                                                }
                                            }
                                            return callback(data);
                                        }
                                    }
                                })
                            } else {
                                return callback(data)
                            }
                        }
                    }
                })
            })
        }
    }
    module.exports = Sdk;
}())