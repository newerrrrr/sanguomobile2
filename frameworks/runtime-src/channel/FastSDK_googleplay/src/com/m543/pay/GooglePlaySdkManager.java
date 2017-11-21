package com.m543.pay;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.m543.pay.iab.PlayBilling;

public class GooglePlaySdkManager {
  
  private static final String TAG = GooglePlaySdkManager.class.getSimpleName();
  
  private static boolean debug = false;
  
  public static boolean isDebug() {
    return debug;
  }
  
  public static void setDebug(boolean debug) {
    GooglePlaySdkManager.debug = debug;
  }
  public static boolean isAvailable(){
     return mPlayBilling.isAvailable();
  }
  
  //已经改为lua配置
  public static String notifyUrl = "http://pay.m543.com/payment/googlePlayNotifyReceiver";
  
  //private static final String PUBLICKEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhfMOTXQ8MeQrefBAorBIXcun03KInBUqGmcXIuS6kA5uG0jH278Vu4rqJYWNNrLWfQcoI7hDb4RmHB+OxyhAZP7KsVzBqlgSgyy5MELTqMUQ/jp6Xg3NXUT6plrVq7ArMDiRaGAzIh43iMzgkF26pT7iE3pXzYPWjXgUPQn8MJNrjHDEaECAz0AkpWaHRSWZlmLfaYVrmcgnKB08Rlv2QBA0ibuhFrVnJQUPF16yPxs2Ji/l6rZ8e/Xbs8Fhh1WzJfIymDuAlaGO7z/dkJ8/LGNfjqZK54ijIBJ9YU5siDrnEoHRqDE0eRizVyX2LB8pbGW1xgXhuU7WCd8db2SwOwIDAQAB";
  
  //private static final String PUBLICKEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqsD8b9M15lwfp4UP+mtQqJJnYlPN/XqIjv2LHLhyb0WfpwvZYpLwQgy4wQFRNsHLhlUPlRIAYKJ/gqKAx1i0wfbJ5KEO62SuiCzHJR5KIzq7CIKswPY5X4KWtHFl2x/sO+a/QVm9huxPi9xbg5oy1xEk22tFRreRSL/8yZxiKDEkaGMHpsCUMLQaE2vU38+8qUpBCMI0zemx2iElumCSSDSKhUAYXOwn5LRfNExT74Miro4v7vourwkJKs+bPhxyqoN1lvFdBlLqbAIH99GzEsOiIBrrv7PA3bhf6dNVUIxCBnmXCuJtROwHhifhe+Ak1f9n6RNdqhtyG4sFiyoDxwIDAQAB";
  
  private static PlayBilling mPlayBilling;
  
  public static void init(Activity activity,String PUBLICKEY) {
    mPlayBilling = PlayBilling.getInstance();
    if (isDebug()) {
      notifyUrl = "http://27.115.98.172:9998/payment/googlePlayNotifyReceiver";
    }
    mPlayBilling.init(activity, PUBLICKEY, notifyUrl);
  }
  
  public static void pay(String orderId, String productId) {
    if (mPlayBilling.isAvailable()) {
      if (mPlayBilling != null) {
    	mPlayBilling.setNotifyUrl(notifyUrl);
        mPlayBilling.purchase(productId, orderId);
      }
    }
  }
  
  public static void release() {
    if (mPlayBilling != null) {
      if (mPlayBilling.isAvailable()) {
        mPlayBilling.release();
      }
    }
  }
  
  public static void onActivityResult(int requestCode, int resultCode,
      Intent data) {
    if (mPlayBilling != null) {
      if (mPlayBilling.isAvailable()) {
        mPlayBilling.handleActivityResult(requestCode, resultCode, data);
      }
    }
  }
  
  public static void log(String text) {
    Log.i(TAG, text);
  }
}
