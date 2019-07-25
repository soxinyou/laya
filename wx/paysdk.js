
const PAY_SERVER_URL = 'https://login.11h5.com/pay';
const PAY_SERVER_URL_KXTOO = 'https://login.kxtoo.com/pay';
const PAY_TEST_SERVER_URL = 'http://115.159.53.187/pay_test';

function pay(args, callback) {

  let domain = args.domain;
  let env = args.env;
  let offerId = args.offerId;
  let gameid = args.gameid;
  let productId = args.productId;
  let productCount = args.productCount || 1;
  let token = args.token;
  let test = Number(args.test);
  let userdata = args.userdata;

  if (isNaN(test)) {
    test = 0; 
  }

  if (typeof env === 'undefined') {
    return callback(-1, '缺少参数env'); 
  }

  if (typeof offerId === 'undefined') {
    return callback(-1, '缺少参数offerId'); 
  }

  if (typeof gameid === 'undefined') {
    return callback(-1, '缺少参数gameid'); 
  }

  if (typeof productId === 'undefined') {
    return callback(-1, '缺少参数productId'); 
  }

  if (typeof token === 'undefined') {
    return callback(-1, '缺少参数token'); 
  }

  // 先下单
  let now = Date.now();
  let serverUrl = PAY_SERVER_URL;
  if (test) {
    serverUrl = PAY_TEST_SERVER_URL;  
  } else {
    if (typeof domain !== 'undefined') {
      if (domain == 'kxtoo') {
        serverUrl = PAY_SERVER_URL_KXTOO; 
      } else if (domain == '11h5') {
        serverUrl = PAY_SERVER_URL; 
      } else {
        return callback(-1, `未知域名参数${domain}`); 
      }
    }
  }

  let url = `${serverUrl}/wxagame2/order.php?gameid=${gameid}&token=${token}&product_id=${productId}&product_count=${productCount}&now=${now}`;
  if (userdata) {
    url += `&userdata=${userdata}`;
  }
  console.log('请求下单url', url);

  wx.request({
    url, 
    success : (res) => {

      let {data, header, statusCode, errMsg} = res;

      console.log('请求下单', data, statusCode);

      if (statusCode != 200) {
        return callback(-1, `支付服务器异常${statusCode}`); 
      }

      if (data.error) {
        return callback(data.error, data.errmsg); 
      }

      let transId = Number(data.trans_id);
      let buyQuantity = Number(data.buy_quantity);

      // 充值游戏币
      wx.requestMidasPayment({
        mode : 'game', 
        env,
        offerId,
        currencyType : "CNY",
        platform: "android",
        buyQuantity,
        zoneId : productId,
        success : () => {

          console.log('充值游戏币成功');

          let now = Date.now();
          let url = `${serverUrl}/wxagame2/buy.php?trans_id=${transId}&token=${token}&now=${now}`;

          // 游戏币兑换道具
          console.log('请求兑换游戏币url', url);
          wx.request({
            url, 
            success : (res) => {

              let {data, statusCode, header, errMsg} = res;

              if (statusCode != 200) {
                return callback(-1, `支付服务器异常${statusCode}`); 
              }

              if (data.error) {
                return callback(data.error, data.errmsg); 
              }

              console.log('兑换游戏币成功');

              return callback(0, '支付成功', transId);
            },
            fail : (res) => {
              console.log('fail', res);
              return callback(-1, '请求支付服务器失败，你的订单将延迟到账，请稍等');
            },
          });
        },
        fail : (res) => {
          let {errCode, errMsg} = res;
          if (errMsg.indexOf('用户取消购买') >= 0) {
            return callback(-1, '用户取消购买'); 
          }
          return callback(-1, `扣款失败${errCode}${errMsg}`);
        }
      });
    },
    fail : (res) => {
      console.log('fail', res);
      return callback(-1, '连接支付服务器失败');
    },
  });
}

module.exports = {
  pay,
};

