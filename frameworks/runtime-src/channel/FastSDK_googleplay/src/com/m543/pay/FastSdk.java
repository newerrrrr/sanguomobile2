package com.m543.pay;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONObject;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer.Result;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;
import com.facebook.share.widget.ShareDialog.Mode;
import com.google.android.gms.analytics.Logger.LogLevel;
import com.google.android.gms.auth.GoogleAuthException;
import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.GoogleApiClient.ConnectionCallbacks;
import com.google.android.gms.common.api.GoogleApiClient.OnConnectionFailedListener;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.plus.Plus;
import com.google.android.gms.plus.model.people.Person;
import com.m543.pay.iab.HttpUtils;
import com.m543.pay.listener.FastSdkInitListener;
import com.m543.pay.listener.FastSdkLogoutListener;
import com.m543.pay.BridgeInterface;

import android.accounts.Account;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentSender;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.appsflyer.AFInAppEventParameterName;
import com.appsflyer.AFInAppEventType;
import com.appsflyer.AppsFlyerLib;
import com.appsflyer.AppsFlyerConversionListener;
import java.util.HashMap;

/**
 * Fast SDK
 */
public class FastSdk {
	private static Activity activity;
	private static GLSurfaceView sGLSurfaceView = null;
	private static String TAG = "GoogleWallet_SDk";
	public static boolean isDebug = false;
	private static boolean isLogin = false;
	private static boolean isPlaying = false;
	private static Handler mHandler = null;
	public static String loginChannel;
	private static int mLuaFunctionId;
	private static ProgressDialog mProgressDialog = null;
	private static String uid = "";
	private static String token = "";
	private static String channel = "";
	/** FBsdk **/
	private static CallbackManager callbackManager;
	private static AccessToken accessToken;
	private static BridgeInterface bridgeInterface = null;
	private static ShareDialog shareDialog = null;
	private static String m_afInfoString = "null";

	/** G+ **/
	/* Request code used to invoke sign in user interactions. */
	private static final int RC_SIGN_IN = 0;

	/* Client used to interact with Google APIs. */
	private static GoogleApiClient mGoogleApiClient;

	/* Is there a ConnectionResult resolution in progress? */
	private static boolean mIsResolving = false;

	/* Should we automatically resolve ConnectionResults when possible? */
	private static boolean mShouldResolve = false;

	public static String SERVER_CLIENT_ID;
	
	private static final String CONFIG = "config";

	public static String getChannel() {
		return channel;
	}

	public static void setChannel(String channel) {
		FastSdk.channel = channel;
	}

	public static String getUid() {
		return uid;
	}

	public static void setUid(String uid) {
		FastSdk.uid = uid;
	}

	public static String getToken() {
		return token;
	}

	public static void setToken(String token) {
		FastSdk.token = token;
	}

	public static int getmLuaFunctionId() {
		return mLuaFunctionId;
	}

	public static void setmLuaFunctionId(int mLuaFunctionId) {
		FastSdk.mLuaFunctionId = mLuaFunctionId;
	}

	public static String getLoginChannel() {
		return loginChannel;
	}

	public static void setLoginChannel(String loginChannel) {
		FastSdk.loginChannel = loginChannel;
	}

	public static boolean isDebug() {
		return isDebug;
	}

	public static void setDebug(boolean isDebug) {
		FastSdk.isDebug = isDebug;
	}

	public static void runOnMainThread(Runnable r) {
		if (null == mHandler) {
			return;
		}
		mHandler.post(r);
	}

	public static boolean isPlaying(String channel) {
		return isPlaying;
	}

	public static void setPlaying(boolean isPlaying) {
		FastSdk.isPlaying = isPlaying;
	}

	public static boolean isLogin(String channel) {
		Log.i(TAG, "isLogin called=" + isLogin);
		return isLogin;
	}

	public static void setLogin(boolean isLogin) {
		FastSdk.isLogin = isLogin;
		if (!isLogin) {
			if (mGoogleApiClient.isConnected()) {
				Plus.AccountApi.clearDefaultAccount(mGoogleApiClient);
				Log.i(TAG, "mGoogleApiClient disconnect....");
				mGoogleApiClient.disconnect();
			}
		}
	}

	private static void initUIHandler() {
		mHandler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				hideLoadingDialog();
				if (msg.obj != null) {
					String message = msg.obj.toString();
					payOrder(message);
				}
				super.handleMessage(msg);
			}
		};
	}
	
	//创建角色事件追踪
	public static void trackCreateRoleEvent() {
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Map<String, Object> eventValue = new HashMap<String, Object>();
				AppsFlyerLib.getInstance().trackEvent(activity.getApplicationContext(),AFInAppEventType.COMPLETE_REGISTRATION,eventValue);
			}
		});
	}
	
	//登录事件追踪
	public static void trackLoginEvent() {
		
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Map<String, Object> eventValue = new HashMap<String, Object>();
				AppsFlyerLib.getInstance().trackEvent(activity.getApplicationContext(),AFInAppEventType.LOGIN,eventValue);
			}
		});
	}
	
	//支付事件追踪
	public static void trackPurchaseEvent(final String revenue,final String contentType,final String contentId,final String currencyType) {
		
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Map<String, Object> eventValue = new HashMap<String, Object>();
				eventValue.put(AFInAppEventParameterName.REVENUE,revenue);//200
				eventValue.put(AFInAppEventParameterName.CONTENT_TYPE,contentType);//"category_a"
				eventValue.put(AFInAppEventParameterName.CONTENT_ID,contentId);//"1234567"
				eventValue.put(AFInAppEventParameterName.CURRENCY,currencyType);//"USD"
				AppsFlyerLib.getInstance().trackEvent(activity.getApplicationContext(),AFInAppEventType.PURCHASE,eventValue);
			}
		});
	}
	
	//新手引导事件追踪（强制引导结束）
	public static void trackTutorialCompletionEvent() {
		
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Map<String, Object> eventValue = new HashMap<String, Object>();
				AppsFlyerLib.getInstance().trackEvent(activity.getApplicationContext(),AFInAppEventType.TUTORIAL_COMPLETION,eventValue);
			}
		});
	}
	
	public static void doCharge(final String url) {
		Log.d(TAG, "googlewallet doCharge url=" + url);
		if (isPlaying(getCurrentChannel())) {
			return;
		}
		setPlaying(true);
		showLoadingDialog();
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					String result = doGet(url);
					Message msg = mHandler.obtainMessage();
					msg.obj = result;
					mHandler.sendMessage(msg);
				} catch (Exception e) {
					setPlaying(false);
					e.printStackTrace();
				}
			}
		}).start();
	}

	public static void payOrder(final String data) {
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				try {
					if (data != null && !"".equals(data)) {
						JSONObject json = new JSONObject(data);
						if ("success".equals(json.getString("status"))) {
							// start to purchase
							String productId = json.getString("productId");
							String orderId = json.getString("orderId");
							if (GooglePlaySdkManager.isAvailable()) {
								GooglePlaySdkManager.pay(orderId, productId);
							} else {
								showToast("安裝的google play　不支持in app billing");
							}
							setPlaying(false);
						} else {
							setPlaying(false);
						}
					} else {
						setPlaying(false);
					}
				} catch (Exception e) {
					setPlaying(false);
					e.printStackTrace();
				}
			}
		});
	}

	public static void purchase(String orderId, String productId,String notifyUrl) {
		
		if (GooglePlaySdkManager.isAvailable()) {
			GooglePlaySdkManager.notifyUrl = notifyUrl;
			GooglePlaySdkManager.pay(orderId, productId);
		} else {
			showToast("安裝的google play　不支持in app billing");
		}
	}
	/**
	 * 显示小文本提示信息
	 * 
	 * @param id
	 */
	public static void showToast(String msg) {
		if (activity != null) {
			Toast.makeText(activity, msg, Toast.LENGTH_SHORT).show();
		}
	}

	/**
	 * 从服务器端获取信息
	 * 
	 * @param strURL
	 * @return
	 */
	public static String doGet(String strURL) {
		// 取得取得默认的HttpClient实例
		DefaultHttpClient httpClient = new DefaultHttpClient();
		// 创建HttpGet实例
		HttpGet request = new HttpGet(strURL);
		try {
			// 连接服务器
			HttpResponse response = httpClient.execute(request);
			// 取得数据记录
			HttpEntity entity = response.getEntity();
			// 取得数据记录内容
			InputStream is = entity.getContent();
			// 显示数据记录内容
			BufferedReader in = new BufferedReader(new InputStreamReader(is));
			String str = "";
			StringBuffer s = new StringBuffer("");
			while ((str = in.readLine()) != null) {
				s.append(str);
			}
			// 释放连接
			httpClient.getConnectionManager().shutdown();
			return s.toString();
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			return null;

		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}

	public static void showLoadingDialog() {
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (mProgressDialog == null) {
					mProgressDialog = new ProgressDialog(activity);
					String message = "正在處理數據...";
					mProgressDialog.setMessage(message);
					mProgressDialog.setCancelable(true);
				}
				if (!mProgressDialog.isShowing()) {
					mProgressDialog.show();
				}
			}
		});
	}

	public static void hideLoadingDialog() {
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				try {
					if (mProgressDialog != null) {
						mProgressDialog.dismiss();
						mProgressDialog = null;
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	private FastSdk() {

	}

	// 获取当前SDK名称
	protected static String getCurrentChannel() {

		return "googlestore";
	}

	// 获取当前SDK版本
	protected static String getCurrentSDKVersion() {

		return "API3";
	}

	/**
	 * SDK 初始化 主要工作：获取本地 assets文件夹下的SDK相关参数并初始化
	 * 
	 * @param mActivity
	 * @param initListener
	 *            ：初始化监听
	 */
	public static void init(Activity mActivity, FastSdkInitListener initListener) {
		activity = mActivity;
		activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				initUIHandler();
			}
		});

		try {
			InputStream is = mActivity.getAssets().open("sdk_params.json");

			byte[] buffer = new byte[is.available()];
			is.read(buffer);
			String json = new String(buffer, "utf-8");
			is.close();
			JSONObject obj;
			obj = new JSONObject(json);
			SERVER_CLIENT_ID = obj.getString("SERVER_CLIENT_ID");

			// FB init
			FacebookSdk.sdkInitialize(mActivity.getApplicationContext());
			// callback Manager
			callbackManager = CallbackManager.Factory.create();
			
			//fb login
			LoginManager.getInstance().registerCallback(callbackManager,new mFacebookCallback());
			
			//fb share
			shareDialog = new ShareDialog(mActivity);
	        shareDialog.registerCallback(callbackManager, new mFacebookShareCallback());

			// G+ init
			mGoogleApiClient = new GoogleApiClient.Builder(activity)
					.addConnectionCallbacks(new mConnectionCallbacks())
					.addOnConnectionFailedListener(
							new mOnConnectionFailedListener()).addApi(Plus.API)
					.addScope(new Scope(Scopes.PROFILE))
					.addScope(new Scope(Scopes.EMAIL)).build();
			// googleplay
			GooglePlaySdkManager.setDebug(isDebug);
			String BASE64_PUBLIC_KEY = obj.getString("BASE64_PUBLIC_KEY");
			GooglePlaySdkManager.init(activity,BASE64_PUBLIC_KEY);

			
			//check本地是否有未发送成功的谷歌订单
			handlerPreviousOrder();
			
			initListener.onSuccess("success");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static void callLuaFunction() {
		final String userInfo = getUid() + "," + getToken() + ","
				+ getChannel();
		//Log.i(TAG, "callLuaFunction: login sdk userInfo(uid,token,channel)="
			//	+ userInfo);
		
		if(bridgeInterface != null)
		{
			bridgeInterface.onLogin(userInfo, getmLuaFunctionId());
		}
	}
	
	public static void shareToFacebook(final int luaFunctionId,final String title,final String description,final String shareUrl,final String imageUrl) {
		setmLuaFunctionId(luaFunctionId);
		doFacebookShare(title,description,shareUrl,imageUrl);
	}

	public static void login(final int luaFunctionId) {
		/**
		 * 请在此处实现SDK登录方法，SDK登录成功才调用luaFunction,登录失败给出本地提示信息
		 */
		
		if (isLogin(getCurrentChannel())) {
			Log.i(TAG, "isLogin(getCurrentChannel()) == true, return");
			return;
		}
		
		Log.i(TAG, "login luaFunctionId=" + luaFunctionId);
		
		mLuaFunctionId = luaFunctionId;

		setmLuaFunctionId(luaFunctionId);

		if (TextUtils.isEmpty(getLoginChannel())) {

			return;
		}

		if ("facebook".equals(getLoginChannel())) {

			doFacebookLogin();
		} else if ("googleplusline".equals(getLoginChannel())) {
			doGoogleplusLogin();
		}
		else if ("googleplus".equals(getLoginChannel())) {
			doGoogleplusLogin();
		}
	}

	// doG+Login
	private static void doGoogleplusLogin() {
		runOnMainThread(new Runnable() {

			@Override
			public void run() {
				mShouldResolve = true;
				mGoogleApiClient.connect();
			}
		});
	}

	// doFBLogin
	private static void doFacebookLogin() {
		runOnMainThread(new Runnable() {

			@Override
			public void run() {
				LoginManager.getInstance().logInWithReadPermissions(activity,
						Arrays.asList("public_profile", "user_friends"));
			}
		});
	}
	
	//doFBShare
	private static void doFacebookShare(final String title,final String description,final String shareUrl,final String imageUrl) {
		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (ShareDialog.canShow(ShareLinkContent.class)) {
				    ShareLinkContent linkContent = new ShareLinkContent.Builder()
				            .setContentTitle(title)
				            .setContentDescription(description)
				            .setContentUrl(Uri.parse(shareUrl))
				            .setImageUrl(Uri.parse(imageUrl))
				            .build();

				    shareDialog.show(linkContent);
				    //shareDialog.show(linkContent, Mode.WEB);
				}
			}
		});
	}
	
	//获取appsflyer conversionData
	public static String getAfConversionData(){
		return m_afInfoString;
	}
	
	//获取appsflyer UID
	public static String getAppsFlyerUID(){
		return AppsFlyerLib.getInstance().getAppsFlyerUID(activity);
	}
	
	private static String simpleMapToJsonStr(Map<String ,String > map){  
        if(map==null||map.isEmpty()){  
            return "null";  
        } 
        String jsonStr = "{";  
        Set<String> keySet = map.keySet();  
        for (Object key : keySet) {  
            jsonStr += "\""+key+"\":\""+map.get(key)+"\",";       
        }  
        jsonStr = jsonStr.substring(0,jsonStr.length()-1);  
        jsonStr += "}";  
        return jsonStr;  
    }  

	/**
	 * activity 生命周期方法调用
	 * 
	 * @param activity
	 */
	public static void onCreate(BridgeInterface var) {
		bridgeInterface = var;
		
		AppsFlyerLib.getInstance().registerConversionListener(activity, new AppsFlyerConversionListener() {
		    @Override
		public void onInstallConversionDataLoaded(Map<String, String> conversionData) {
		        for (String attrName : conversionData.keySet()) {
		            Log.d(AppsFlyerLib.LOG_TAG, "attribute: " + attrName + " = " + 
		            	conversionData.get(attrName));
		        }
		        
		        m_afInfoString = simpleMapToJsonStr(conversionData);
		    }
		    @Override
		    public void onInstallConversionFailure(String errorMessage) {
		        Log.d(AppsFlyerLib.LOG_TAG, "error getting conversion data: " + 
		        		errorMessage);
		    }
		    @Override
		    public void onAppOpenAttribution(Map<String, String> conversionData) {
		    }
		    @Override
		    public void onAttributionFailure(String errorMessage) {
		        Log.d(AppsFlyerLib.LOG_TAG, "error onAttributionFailure : " + errorMessage);
		    }
		});
		
		
		AppsFlyerLib.getInstance().startTracking(activity.getApplication(),"oGb6cApNBeVH4iGMYPW2cW");
	}

	public static void onResume() {
	
	}

	public static void onPause() {
	}

	public static void onStop() {

	}

	public static void onRestart() {

	}

	public static void onDestroy() {

	}

	public static void onStart() {

	}

	public static void onNewIntent(Intent intent) {

	}

	// callBack result
	public static void onActivityResult(int requestCode, int resultCode,
			Intent data) {

		callbackManager.onActivityResult(requestCode, resultCode, data);

		if (requestCode == RC_SIGN_IN) {
			if (resultCode != activity.RESULT_OK) {
				mShouldResolve = false;
			}
			mIsResolving = false;
			mGoogleApiClient.connect();
		}

		isPlaying = false;
		GooglePlaySdkManager.onActivityResult(requestCode, resultCode, data);

	}

	public static void setGLSurfaceView(GLSurfaceView value) {
		sGLSurfaceView = value;
	}

	public static void runOnGLThread(Runnable r) {
		if (null != sGLSurfaceView) {
			sGLSurfaceView.queueEvent(r);
		} else {
			r.run();
		}
	}

	/**
	 * 退出接口
	 */
	public static void exit() {
		if (activity != null) {
			if (mGoogleApiClient.isConnected()) {
				Plus.AccountApi.clearDefaultAccount(mGoogleApiClient);
				mGoogleApiClient.disconnect();
			}
			activity.finish();
			android.os.Process.killProcess(android.os.Process.myPid());
			System.exit(0);
		}
	}

	/**
	 * 登出接口
	 * 
	 * @param customParams
	 *            ：客户端参数，原样返回
	 * @param logoutListener
	 *            ：登出监听
	 */
	public static void logout(Object customParams,
			FastSdkLogoutListener logoutListener) {

		runOnMainThread(new Runnable() {
			@Override
			public void run() {
				AlertDialog.Builder alertbBuilder = new AlertDialog.Builder(
						activity);
				alertbBuilder
						.setTitle("提示")
						.setMessage("是否退出游戏？")
						.setPositiveButton("确定",
								new DialogInterface.OnClickListener() {
									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										GooglePlaySdkManager.release();
										exit();
									}
								})
						.setNegativeButton("取消",
								new DialogInterface.OnClickListener() {
									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										dialog.cancel();
									}
								}).create();
				alertbBuilder.show();
			}
		});

	}
	
	// FB share callback
	public static class mFacebookShareCallback implements
			FacebookCallback<Result>
	{
		//分享成功
		@Override
		public void onSuccess(Result ret) {
			
			final String shareInfo = "success";
			//call lua func
			if(bridgeInterface != null)
			{
				bridgeInterface.onShare(shareInfo, getmLuaFunctionId());
			}
		}
		
		@Override
		public void onError(FacebookException arg0) {
			Log.i(TAG, "facebook share error:" + arg0.getMessage());
			final String shareInfo = "error";
			//call lua func
			if(bridgeInterface != null)
			{
				bridgeInterface.onShare(shareInfo, getmLuaFunctionId());
			}
		}

		@Override
		public void onCancel() {
			final String shareInfo = "cancled";
			//call lua func
			if(bridgeInterface != null)
			{
				bridgeInterface.onShare(shareInfo, getmLuaFunctionId());
			}
		}
	}
		

	// FB login callback
	public static class mFacebookCallback implements
			FacebookCallback<LoginResult> {
		// 登入成功
		@Override
		public void onSuccess(LoginResult arg0) {
			accessToken = arg0.getAccessToken();
			GraphRequest request = GraphRequest.newMeRequest(accessToken,
					new GraphRequest.GraphJSONObjectCallback() {

						// 當RESPONSE回來的時候

						@Override
						public void onCompleted(JSONObject object,
								GraphResponse response) {

							// 讀出姓名 ID FB個人頁面連結
							setUid(object.optString("id"));
							setToken(object.optString("id"));
							setChannel("facebook");
							callLuaFunction();
							setLogin(true);

						}
					});

			// 包入你想要得到的資料 送出request

			Bundle parameters = new Bundle();
			parameters.putString("fields", "id,name,link");
			request.setParameters(parameters);
			request.executeAsync();
		}

		@Override
		public void onError(FacebookException arg0) {
			Log.i(TAG, "facebook login error:" + arg0.getMessage());
			LoginManager.getInstance().logOut();
			setLogin(false);
		}

		@Override
		public void onCancel() {

		}

	}

	// G+ callback
	public static class mConnectionCallbacks implements ConnectionCallbacks {

		@Override
		public void onConnectionSuspended(int arg0) {

		}

		@Override
		public void onConnected(Bundle arg0) {
			Log.i(TAG, "GoogleApiClient onConnected");
			Person person = Plus.PeopleApi.getCurrentPerson(mGoogleApiClient);
			
			//Log.i(TAG, "audience:server:client_id:" + SERVER_CLIENT_ID);
			
			String currentPersonName = person != null ? person.getDisplayName()
					: "未知用户";

			Log.i(TAG, "GoogleApiClient onConnected currentPersonName===="
					+ currentPersonName);
			new GetIdTokenTask().execute();

		}
	}

	public static class mOnConnectionFailedListener implements
			OnConnectionFailedListener {

		@Override
		public void onConnectionFailed(ConnectionResult arg0) {
			Log.d(TAG, "onConnectionFailed:" + arg0);

			if (!mIsResolving && mShouldResolve) {
				if (arg0.hasResolution()) {
					try {
						arg0.startResolutionForResult(activity, RC_SIGN_IN);
						mIsResolving = true;
					} catch (IntentSender.SendIntentException e) {
						mIsResolving = false;
						mGoogleApiClient.connect();
					}
				} else {
					// show error dialog
					GooglePlayServicesUtil.getErrorDialog(arg0.getErrorCode(),
							activity, 0).show();
					return;
				}
			} else {
				// Show the signed-out UI
			}

		}
	}

	// getLocalToken
	private static class GetIdTokenTask extends AsyncTask<Void, Void, String> {

		@Override
		protected String doInBackground(Void... params) {
			String accountName = Plus.AccountApi
					.getAccountName(mGoogleApiClient);
			Account account = new Account(accountName,
					GoogleAuthUtil.GOOGLE_ACCOUNT_TYPE);
			
			String scopes = "audience:server:client_id:" + SERVER_CLIENT_ID;
			try {
				return GoogleAuthUtil.getToken(
						activity.getApplicationContext(), account, scopes);
			} catch (IOException e) {
				return null;
			} catch (GoogleAuthException e) {
				return null;
			}
		}

		@Override
		protected void onPostExecute(String result) {
			if (result != null) {
				setUid(result);
				setToken(result);
				setChannel("googleplus");
				setLogin(true);
				callLuaFunction();
			}
		}

	}
	
	
	
	/**
	 * 工具方法,缓存本地订单信息
	 */
	public static String getString(Context mContext, String key) {
		if (mContext != null) {
			SharedPreferences sp = mContext.getSharedPreferences(CONFIG,
					Context.MODE_PRIVATE);
			return sp.getString(key, null);
		}
		return null;
	}

	public static void putString(Context mContext, String key, String value) {
		if (mContext != null) {
			SharedPreferences sp = mContext.getSharedPreferences(CONFIG,
					Context.MODE_PRIVATE);
			Editor mEditor = sp.edit();
			mEditor.putString(key, value);
			mEditor.commit();
		}
	}

	public static void removeString(Context mContext, String key) {
		if (mContext != null) {
			SharedPreferences sp = mContext.getSharedPreferences(CONFIG,
					Context.MODE_PRIVATE);
			Editor mEditor = sp.edit();
			mEditor.remove(key);
			mEditor.commit();
		}
	}
	
	
	/**
	 * 本地检测是否有未发送成功的谷歌订单，如果有，继续发送
	 * 此处不再循环发送
	 */
	private static void  handlerPreviousOrder(){		
		final String purchaseData = getString(activity,"purchaseData");
		final String dataSignature = getString(activity,"signature");
		if (purchaseData != null  && dataSignature != null ) {
			// 异步处理订单信息
			new Thread(new Runnable() {
				@Override
				public void run() {
					List<NameValuePair> entity = new ArrayList<NameValuePair>();

					entity.add(new BasicNameValuePair("responseData",
							purchaseData));

					entity.add(new BasicNameValuePair("signature",
							dataSignature));

					String result = HttpUtils.doPost(entity,
							GooglePlaySdkManager.notifyUrl);

					Log.i("handlePreviousOrder", "handlePreviousOrder result="
							+ result);

					if (result != null && "success".equals(result)) {
						  removeString(activity,"purchaseData");
			              removeString(activity,"signature");
					}
				}
			}).start();
		}
	
	}
	
	
	
	


	
	
	
	

}
