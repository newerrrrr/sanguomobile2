package com.m543.pay.iab;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import com.m543.pay.FastSdk;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

public class PlayBilling {

  private static final String TAG = PlayBilling.class.getSimpleName();
  
  private static final int REQUEST_CODE=20140604;

  private Activity mContext;

  private IabHelper mHelper;

  private boolean available = false;

  private boolean logDebug;

  private List<Order> preparedList = new ArrayList<Order>();
  
  private String notifyUrl;
  
  private Inventory owns=null;

  private PlayBilling() {
  }

  static class SingletonHolder {
    static PlayBilling instance = new PlayBilling();
  }

  public static PlayBilling getInstance() {
    return SingletonHolder.instance;
  }
  public boolean isAvailable() {
    return available;
  }

  public void setAvailable(boolean available) {
    this.available = available;
  }
  
  public void setNotifyUrl(String notifyUrl){
	this.notifyUrl = notifyUrl;
  }
  
  public String getNotifyUrl(){
	return this.notifyUrl;
  }
  
  public boolean isLogDebug() {
    return logDebug;
  }
  /**
   * 添加待购买订单
   * @param order
   */
  public void addOrder(Order order) {
    if (!preparedList.contains(order)) {
      preparedList.add(order);
    }
  }
  /**
   * 删除待购买订单
   * @param order
   */
  public void removeOrder(Order order) {
    if (preparedList.contains(order)) {
      preparedList.remove(order);
    }
  }
  public boolean isExist(String productId){
    if(owns!=null){
      return owns.hasPurchase(productId);
    }
    return false;
  }

  /**
   * 是否输出日志
   * 
   * @param logDebug
   */
  public void setLogDebug(boolean logDebug) {
    this.logDebug = logDebug;
    mHelper.enableDebugLogging(true);
  }

  /**
   * 初始化 建议在Activity的onCreate()方法中调用
   * 
   * @param mContext
   * @param publicKey
   */
  public void init(Activity mContext, String publicKey,String notifyUrl) {
    this.mContext = mContext;
    this.notifyUrl=notifyUrl;
    //Log.i(TAG, "notifyUrl="+notifyUrl);
    mHelper = new IabHelper(this.mContext, this.mContext, publicKey);
    mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
      public void onIabSetupFinished(IabResult result) {
        Log.d(TAG, "Setup finished.");
        if (!result.isSuccess()) {
          Log.d(TAG, "Problem setting up in-app billing: " + result.toString());
          return;
        }
        // Have we been disposed of in the meantime? If so, quit.
        if (mHelper == null) {
          return;
        }
        // IAB is fully set up. Now, let's get an inventory of stuff we own.
        Log.d(TAG, "Setup successful. Querying inventory.");
        available = true;
        mHelper.queryInventoryAsync(mGotInventoryListener);
      }
    });
  }
  /**
   * 查询库存监听
   */
  private IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
    public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
      Log.d(TAG, "Query inventory finished.");
      // Have we been disposed of in the meantime? If so, quit.
      if (mHelper == null) {
        return;
      }
      // Is it a failure?
      if (result.isFailure()) {
        Log.d(TAG, "Failed to query inventory: " + result);
        return;
      }
      Log.d(TAG, "Query inventory was successful.");
      if (inventory != null) {
        owns=inventory;
      }else{
        owns=new Inventory();
      }
    }
  };
  /**
   * 购买监听
   */
  private IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
    public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
        // if we were disposed of in the meantime, quit.
        if (mHelper == null){
          return;
        }
        if (result.isFailure()) {
            Log.d(TAG,"Error purchasing: " + result.toString());
            return;
        }
        if(owns!=null){//加入库存
           Log.d(TAG,"加入库存............");
           owns.addPurchase(purchase);
        }
        Log.d(TAG, "Purchase successful.");
        mHelper.consumeAsync(purchase, mConsumeFinishedListener);
    }
};

/**
 * 消费监听
 */
private IabHelper.OnConsumeFinishedListener mConsumeFinishedListener = new IabHelper.OnConsumeFinishedListener() {
  public void onConsumeFinished(Purchase purchase, IabResult result) {
      Log.d(TAG, "onConsumeFinished...");
      // if we were disposed of in the meantime, quit.
      if (mHelper == null){
        return;
      }
      if (result.isSuccess()) {
        if(owns!=null){//从库存中移除
           Log.d(TAG, "onConsumeFinished erasePurchase...");
           owns.erasePurchase(purchase.getSku());
        }
        Log.d(TAG,"Consume purchase="+purchase.toString());
        //缓存本地已完成订单信息
        FastSdk.putString(mContext,"purchaseData", purchase.getOriginalJson());
        FastSdk.putString(mContext,"signature", purchase.getSignature());
        notifyServer(purchase);
        if(preparedList!=null&&preparedList.size()>0){
          Order order=preparedList.get(0);
          if(purchase(order.getSku(),order.getPayLoad())){
            removeOrder(order);
          }
        }
      }else {
        Log.d(TAG,"Error while consuming: " + result.toString());
      }
  }
};
  public boolean purchase(final String sku,final String payload){
    if(isExist(sku)){//已经拥有
       if(mHelper!=null){
         Purchase purchase=owns.getPurchase(sku);
         mHelper.consumeAsync(purchase, mConsumeFinishedListener);
         addOrder(new Order(sku,payload));
       }
       return false;
     }else{//未拥有
       if(mHelper!=null){
         mContext.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            mHelper.launchPurchaseFlow(mContext, sku, REQUEST_CODE,mPurchaseFinishedListener, payload);
          }
        });
       }
       return true;
     }
  }
  /**
   * 必须在onActivityResult中调用
   * @param requestCode
   * @param resultCode
   * @param data
   * @return
   */
  public boolean handleActivityResult(int requestCode, int resultCode, Intent data){
     return mHelper.handleActivityResult(requestCode, resultCode, data);
  }
  /**
   * 异步处理订单信息
   * @param purchase
   * 服务器返回success表示客户端所发信息以及成功接收，不代表结果是否正确
   */
  private void notifyServer(final Purchase purchase){	  
    new Thread(new Runnable() {
      @Override
      public void run() {
        boolean arrived=false;
        int total=10;
        while(!arrived&&total>0){
          try {
            String result=post(purchase);
            if (result != null && "success".equals(result)) {
              arrived=true;
              Log.i("nbahero googleplay","googleplay post url success");
              //发送成功，移除本地缓存订单
              FastSdk.removeString(mContext,"purchaseData");
              FastSdk.removeString(mContext,"signature");
            }
            total--;
            try {
              Thread.sleep(10000);
            } catch (InterruptedException e) {
              e.printStackTrace();
            }
          } catch (Exception e) {
            e.printStackTrace();
          }
        }
      }
    }).start();
  }
  private String post(final Purchase purchase){
    List<NameValuePair> entity = new ArrayList<NameValuePair>();
    entity.add(new BasicNameValuePair("responseData",purchase.getOriginalJson()));
    entity.add(new BasicNameValuePair("signature",purchase.getSignature()));
    String result = HttpUtils.doPost(entity,notifyUrl);
    return result;
  }
  /**
   * 必须在onDestroy中调用
   */
  public void release(){
    if (mHelper != null) {
      mHelper.dispose();
      mHelper = null;
    }
  }
  
  

}
