package demo;

import java.io.InputStream;

import layaair.autoupdateversion.AutoUpdateAPK;
import layaair.game.IMarket.IPlugin;
import layaair.game.IMarket.IPluginRuntimeProxy;
import layaair.game.Market.GameEngine;
import layaair.game.config.config;

import com.game.usdk.GameUSDK;
import com.game.usdk.listener.GameUExitListener;
import com.game.usdk.listener.GameUInitListener;
import com.game.usdk.listener.GameUSwitchAccountListener;
import com.h5.SDKManager;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.ConnectivityManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.ValueCallback;


public class MainActivity extends Activity {
    public static final int AR_CHECK_UPDATE = 1;
    private IPlugin mPlugin = null;
    private IPluginRuntimeProxy mProxy = null;
    boolean isLoad = false;
    boolean isExit = false;
    public static SplashDialog mSplashDialog;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        JSBridge.mMainActivity = this;
        SDKManager.OnInited(this);

        mSplashDialog = new SplashDialog(this);
        mSplashDialog.showSplash();

        //设置切换账号事件
        GameUSDK.getInstance().setSwitchAccountListener(new GameUSwitchAccountListener() {
            @Override
            public void logoutSuccess() {
                //游戏处理为回到游戏的登录场景页
                System.out.println("MLog------->setSwitchAccountListener:切换账号成功");
//                ToastUtil.toast(MainActivity.this, "切换账号成功，回到游戏登录场景页，以便用户重新发起登录");
                SDKManager.OnSwitchAccount();
            }

            @Override
            public void logoutFail(int code, String errMsg) {
                Log.e("GameUSDK", "logoutFail,code=" + code + "msg:" + errMsg);
            }
        });



        //周期方法 - onCreate() 必接
        GameUSDK.getInstance().onCreate(this, savedInstanceState);
        //初始化 - *注意* 需先添加全局回调事件后，再调用init
        GameUSDK.getInstance().init(this, new GameUInitListener() {
            @Override
            public void initSuccess() {
                SDKManager.OnStart();
            }

            @Override
            public void initFail(int code, String msg) {
                System.out.println("初始化失败，code:" + code + ",msg:" + msg);
//                ToastUtil.toast(MainActivity.this, "初始化失败，code:" + code + ",msg:" + msg);
            }
        });

        /*
         * 如果不想使用更新流程，可以屏蔽checkApkUpdate函数，直接打开initEngine函数
         */
        //checkApkUpdate(this);
        initEngine();
    }

    public void initEngine()
    {
        mProxy = new RuntimeProxy(this);
        mPlugin = new GameEngine(this);
        mPlugin.game_plugin_set_runtime_proxy(mProxy);
        mPlugin.game_plugin_set_option("localize","false");
        mPlugin.game_plugin_set_option("gameUrl", "http://res1.cqjy.5jli.com/cqjy_res_main/index_app.html");
//        mPlugin.game_plugin_set_option("gameUrl", "http://res1.cqjy.5jli.com/cqjy_res_main_test/index_app.html");
//        mPlugin.game_plugin_set_option("gameUrl", "http://res1.cqjy.5jli.com/cqjy_res_register/index_app.html");
        mPlugin.game_plugin_init(3);
        View gameView = mPlugin.game_plugin_get_view();
        this.setContentView(gameView);
        isLoad=true;
    }
    public  boolean isOpenNetwork(Context context)
    {
        if (!config.GetInstance().m_bCheckNetwork)
            return true;
        ConnectivityManager connManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        return connManager.getActiveNetworkInfo() != null && (connManager.getActiveNetworkInfo().isAvailable() && connManager.getActiveNetworkInfo().isConnected());
    }
    public void settingNetwork(final Context context, final int p_nType)
    {
        AlertDialog.Builder pBuilder = new AlertDialog.Builder(context);
        pBuilder.setTitle("连接失败，请检查网络或与开发商联系").setMessage("是否对网络进行设置?");
        // 退出按钮
        pBuilder.setPositiveButton("是", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface p_pDialog, int arg1) {
                Intent intent;
                try {
                    String sdkVersion = Build.VERSION.SDK;
                    if (Integer.valueOf(sdkVersion) > 10) {
                        intent = new Intent(
                                android.provider.Settings.ACTION_WIRELESS_SETTINGS);
                    } else {
                        intent = new Intent();
                        ComponentName comp = new ComponentName(
                                "com.android.settings",
                                "com.android.settings.WirelessSettings");
                        intent.setComponent(comp);
                        intent.setAction("android.intent.action.VIEW");
                    }
                    ((Activity)context).startActivityForResult(intent, p_nType);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        pBuilder.setNegativeButton("否", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
                ((Activity)context).finish();
            }
        });
        AlertDialog alertdlg = pBuilder.create();
        alertdlg.setCanceledOnTouchOutside(false);
        alertdlg.show();
    }
    public  void checkApkUpdate( Context context,final ValueCallback<Integer> callback)
    {
        if (isOpenNetwork(context)) {
            // 自动版本更新
            if ( "0".equals(config.GetInstance().getProperty("IsHandleUpdateAPK","0")) == false ) {
                Log.e("0", "==============Java流程 checkApkUpdate");
                new AutoUpdateAPK(context, new ValueCallback<Integer>() {
                    @Override
                    public void onReceiveValue(Integer integer) {
                        Log.e("",">>>>>>>>>>>>>>>>>>");
                        callback.onReceiveValue(integer);
                    }
                });
            } else {
                Log.e("0", "==============Java流程 checkApkUpdate 不许要自己管理update");
                callback.onReceiveValue(1);
            }
        } else {
            settingNetwork(context,AR_CHECK_UPDATE);
        }
    }
    public void checkApkUpdate(Context context) {
        InputStream inputStream = getClass().getResourceAsStream("/assets/config.ini");
        config.GetInstance().init(inputStream);
        checkApkUpdate(context,new ValueCallback<Integer>() {
            @Override
            public void onReceiveValue(Integer integer) {
                if (integer.intValue() == 1) {
                    initEngine();
                } else {
                    finish();
                }
            }
        });
    }
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == AR_CHECK_UPDATE) {
            checkApkUpdate(this);
        }
        GameUSDK.getInstance().onActivityResult(requestCode, resultCode, intent);
    }


    @Override
    public void onNewIntent(Intent newIntent) {
        super.onNewIntent(newIntent);

        GameUSDK.getInstance().onNewIntent(newIntent);

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        System.out.println("------->run onKeyDown");
        if(event.getKeyCode() == KeyEvent.KEYCODE_BACK){

            if(SDKManager.logined==true){
                /**
                 * 模拟游戏退出
                 */
                GameUSDK.getInstance().exit(MainActivity.this, new GameUExitListener() {
                    @Override
                    public void exitSuccess() {
                        //cp在此处真实退出游戏
                        MainActivity.this.finish();
                        JSBridge.mMainActivity = null;

                        SDKManager.OnFinish();
                        System.exit(0);
                    }
                });
                return false;
            }else{
                return true;
            }

        }else {
            return super.onKeyDown(keyCode,event);
        }
    }

    @Override
    protected void onStart() {
        super.onStart();

        GameUSDK.getInstance().onStart();
    }

    @Override
    public void onRestart() {
        super.onRestart();

        GameUSDK.getInstance().onRestart();
    }

    protected void onPause() {
        super.onPause();
        GameUSDK.getInstance().onPause();
        if (isLoad) mPlugin.game_plugin_onPause();
    }

    //------------------------------------------------------------------------------
    protected void onResume() {
        super.onResume();
        GameUSDK.getInstance().onResume();
        if (isLoad) mPlugin.game_plugin_onResume();

    }

    @Override
    protected void onStop() {
        super.onStop();
        GameUSDK.getInstance().onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        GameUSDK.getInstance().onDestroy();
        if (isLoad) mPlugin.game_plugin_onDestory();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        GameUSDK.getInstance().onConfigurationChanged(newConfig);
    }


    @TargetApi(Build.VERSION_CODES.M)
    /**
     * 若编译的targetSdkVersion >= 23，则需覆盖，否则注释此方法
     */
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        GameUSDK.getInstance().onRequestPermissionResult(requestCode, permissions, grantResults);
    }
}