package com.h5;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import demo.JSBridge;
import layaair.game.browser.ExportJavaFunction;

import com.game.usdk.GameUSDK;
import com.game.usdk.listener.GameULoginListener;
import com.game.usdk.listener.GameUPayListener;
import com.game.usdk.model.GameUGameData;
import com.game.usdk.model.GameUOrder;
import com.game.usdk.model.GameUser;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class SDKManager {
    public static String gameid="26";
    public static boolean logined=false;

    static String appid=null;
    static Context mact=null;
    static String imei=null;

    static List<String> m_oncallTemp = new ArrayList<String>();
    public static void OnCall(String json) {
        MLog("========================原生被as调用："+json);
        if(appid !=null){
            CommandExe(json);
        }else{
            m_oncallTemp.add(json);
        }
    }

    public static void OnInited(Context cxt){
        mact=cxt;
        imei=DeviceInfoUtil.getIMEI(cxt);
        logined=false;

        MLog("SDKManager OnInited");
    }

    public static void  OnStart(){
        MLog("OnStart");

        appid=GameUSDK.getInstance().getPlatformId();

        for (int i = 0; i < m_oncallTemp.size(); i++) {
            CommandExe( m_oncallTemp.get(i));
        }
        m_oncallTemp.clear();
    }

    public static void OnFinish(){
        mact=null;
        logined=false;
        m_oncallTemp.clear();
    }

    static void CallToJs(String cmd,Object cxt) {

        MLog("======================== run CallToJs："+cmd);
        JSONObject  obj =new JSONObject();
        try{
            obj.put("cmd",cmd);
            JSONObject cxtJon;
            if(cxt==null){
                cxtJon=new JSONObject();
            }else{
                cxtJon=(JSONObject)cxt;
            }
            obj.put("cxt",cxtJon);
        }catch (Exception e) {
            e.printStackTrace();
        }
        String json = obj.toString();

        ExportJavaFunction.CallBackToJS(SDKManager.class,"OnCall",json);
    }

    static void CommandExe(String json) {
        try{
            JSONObject obj_main = new JSONObject(json);
            final String cmd = obj_main.optString("cmd","");
            final JSONObject obj = obj_main.getJSONObject("cxt");

            MLog("+++++++++++++++++++++ run CommandExe:"+cmd);

            ((Activity)mact).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(cmd.equalsIgnoreCase("connect")){
                        OnConnect();
                    }
                    else if(cmd.equalsIgnoreCase("login")){
                        JSBridge.forceHideSplash();
                        OnLogin();
                    }
                    else if(cmd.equalsIgnoreCase("pay")){
                        OnPay(obj);
                    }
                    else if(cmd.equalsIgnoreCase("create_role")){
                        OnRoleReport(GameUGameData.GAMEDATA_TYPE_CREATE_ROLE,obj);
                    }
                    else if(cmd.equalsIgnoreCase("selected_server")){
                        OnRoleReport(GameUGameData.GAMEDATA_TYPE_PRE_CREATE_ROLE,obj);
                    }
                    else if(cmd.equalsIgnoreCase("enter_game")){
                        OnRoleReport(GameUGameData.GAMEDATA_TYPE_ENTER_GAME,obj);
                    }
                    else if(cmd.equalsIgnoreCase("role_update")){
                        OnRoleReport(GameUGameData.GAMEDATA_TYPE_ROLE_UPDATE,obj);
                    }

                    else if(cmd.equalsIgnoreCase("logout")){
                        OnLogout();
                    }
                }
            });

        }catch (Exception e){
            e.printStackTrace();
        }
    }

    /**
     * 获取当前应用程序的包名
     * @param context 上下文对象
     * @return 返回包名
     */
    static String getAppProcessName(Context context) {
        //当前应用pid
        int pid = android.os.Process.myPid();
        //任务管理类
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        //遍历所有应用
        List<ActivityManager.RunningAppProcessInfo> infos = manager.getRunningAppProcesses();
        for (ActivityManager.RunningAppProcessInfo info : infos) {
            if (info.pid == pid)//得到当前应用
                return info.processName;//返回包名
        }
        return "";
    }

    static void OnConnect() {
        JSONObject cxt =new JSONObject();
        String packageName = getAppProcessName(mact);
        String packageVersion="";
        String appName = "";
        if(packageName!=null){
            PackageManager pm = mact.getPackageManager();
            try {
                PackageInfo packinfo = pm.getPackageInfo(packageName, 0);
                packageVersion= packinfo.versionName;
                ApplicationInfo info = pm.getApplicationInfo(packageName, 0);
                appName= info.loadLabel(pm).toString();
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        }

        try {
            cxt.put("result",1);
            if(packageName!=null){
                cxt.put("bundle_id",packageName);
                cxt.put("bundle_version",packageVersion);
                cxt.put("display_name",appName);
                cxt.put("phone_model",DeviceInfoUtil.getPhoneModel());

                MLog("bundle_id:"+packageName+",bundle_version:"+packageVersion+",display_name:"+appName);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        CallToJs("connect",cxt);
    }

    static void OnLogin(){
        GameUSDK.getInstance().login(mact, new GameULoginListener() {
            @Override
            public void loginSuccess(GameUser user) {
                String token = user.getToken();
                String loginLogInfo = "登入成功 \n token:" +token;
                logined=true;
//                GameUSDK.getInstance().getParams()
                MLog(loginLogInfo);
               // ToastUtil.toast(mact, loginLogInfo);
                JSONObject info =new JSONObject();
                try {
                    info.put("appid",appid);
                    info.put("gameid",gameid);
                    info.put("token",token);
                    info.put("clientid",user.getUid());
                    info.put("imei",imei);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                CallToJs("login",info);
            }

            @Override
            public void loginFail(int code, String errMsg) {
                MLog("登录失败：\n" + errMsg);
//                ToastUtil.toast(mact, "登录失败：\n" + errMsg);
            }
        });
    }
    static void OnPay(JSONObject info){
        final GameUOrder order = new GameUOrder();
        //*必填* cp的订单ID，供对账用，需要替换为真实值
        order.setCpOrderId(info.optString("order_no",""));

        //*必填* 商品ID，需要替换为真实值
        order.setProductId(info.optString("product_id",""));

        //*必填* 商品名称，如钻石、元宝
        order.setProductName(info.optString("subject",""));

        double money=info.optDouble("money",0.00);
        int coin=info.optInt("game_coin");
        //*必填* 商品实际支付的总价格，单位为 "元"
        order.setRealPayMoney((float)money);

        //*必填* 1人民币兑换元宝的个数，例如 10
        int radio =(int)((double)coin/money);

        MLog("recharge---> coin/money:"+radio);

        order.setRadio(radio);

        //*必填* 服务器ID,需要替换为真实值
        order.setServerId(info.optInt("sid"));

        //*必填* 服务器名称,需要替换为真实值
        order.setServerName(info.optString("servername"));

        //*必填* 角色ID，需要替换为真实值
        order.setRoleId(info.optString("actor_id"));

        //*必填* 角色名，需要替换为真实值
        order.setRoleName(info.optString("rolename"));

        //*必填* 订单创建时间，需要替换为服务器下发的真实值
        order.setOrderTime(info.optString("time","-1"));

        //*必填* 研发后端按照服务器充值文档对订单数据生成签名，需要替换为真实值
        order.setSign(info.optString("sign"));

        //cp 透传字段，充值完成后完整回调给CP设置的发货地址，详见文档
        order.setExt(info.optString("ext"));

        ((Activity)mact).runOnUiThread(new Runnable() {
            @Override
            public void run() {

                GameUSDK.getInstance().pay(mact, order, new GameUPayListener() {
                    @Override
                    public void paySuccess() {
                        MLog("支付成功" );
                    }

                    @Override
                    public void payFail(int code, String msg) {
                        MLog("支付失败，msg:" + msg);
//                        ToastUtil.toast(mact, "支付失败，msg:" + msg);
                    }
                });

            }
        });


    }
    static void OnRoleReport(int dataType,JSONObject info){

        MLog("OnRoleReport---> dataType:"+dataType);

        GameUGameData gameData = new GameUGameData();
        gameData.setDataType(dataType);
        gameData.setZoneId(info.optString("serverid",""));//服id,默认传""
        gameData.setZoneName(info.optString("servername",""));//服名称,默认传""
        gameData.setRoleId(info.optString("roleid",""));//角色id,默认传""
        gameData.setRoleName(info.optString("rolename",""));//角色名,默认传""
        gameData.setPartyName(info.optString("country","")); //无帮派则默认传""
        gameData.setVipLevel(info.optString("viplevel","0")); //无vip则默认传"0"
        gameData.setBalance((float) info.optDouble("balance",0.00));   //用户余额（RMB 购买的游戏币,例如钻石）
        gameData.setRoleLevel(info.optInt("rolelevel",0));//角色等级,默认传0

        //角色创建时间（单位：秒）（历史角色没记录时间的传 -1，新创建的角色必须要）
        gameData.setRoleCTime(info.optString("rolecreatetime","-1"));
        //角色等级变化时间（单位：秒）（创建角色和进入游戏时传 -1）
        gameData.setRoleLevelMTime(info.optString("timestamp","-1"));
        GameUSDK.getInstance().reportData(gameData);
//        ToastUtil.toast(mact,"role_report--> " + gameData.toString());
    }

    public static void OnLogout(){
//        CallToJs("logout",null);
    }

    public static void OnSwitchAccount(){
        CallToJs("switch_account",null);
    }

    static void MLog(String val){
        System.out.println("MLog------->"+val);
    }
}