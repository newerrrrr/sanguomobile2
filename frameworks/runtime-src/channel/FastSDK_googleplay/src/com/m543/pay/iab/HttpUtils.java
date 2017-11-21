package com.m543.pay.iab;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreConnectionPNames;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * 完成http请求
 * @author David
 */
public class HttpUtils {
	private static HttpUtils instance;
	private HttpUtils(){
		
	}
	public static HttpUtils getInstance(){
		if(instance==null){
			instance=new HttpUtils();
		}
		return instance;
	}
	/**
	 * 从服务器端获取信息
	 * @param strURL
	 * @return
	 */
	public static String doGet(String strURL)throws Exception {
		// 取得取得默认的HttpClient实例
		DefaultHttpClient httpClient = new DefaultHttpClient();
		// 创建HttpGet实例
		HttpGet request = new HttpGet(strURL);
			// 连接服务器
			HttpResponse response = httpClient.execute(request);
			
			if(response.getStatusLine().getStatusCode()==HttpStatus.SC_OK){
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
			}
			return null;
		
	}
	/**
	 * 检测网络是否可用
	 * @param context 上下文对象
	 * @return true or false
	 */
	public static boolean isNetworkAvailable(Context context) { 
		if(context==null)return false;
		String netWork=Context.CONNECTIVITY_SERVICE;
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(netWork);   
        if (cm == null){   
        } else {   
            NetworkInfo[] info = cm.getAllNetworkInfo();   
            if (info != null) {   
                for (int i = 0; i < info.length; i++) {   
                    if (info[i].getState() == NetworkInfo.State.CONNECTED) {   
                        return true;   
                    }   
                }   
            }   
        }   
        return false;   
    }  
	 
	  public static String doPost(List<NameValuePair> params,String url){
			
		    //返回结果
		    String result=null;
			
			//新建HttpPost对象
			HttpPost httpPost=new HttpPost(url);
			
			try {
				//设置字符集
				HttpEntity httpEntity=new UrlEncodedFormEntity(params,HTTP.UTF_8);
				//设置请求参数实体
				httpPost.setEntity(httpEntity);
				//获取HttpClient对象
				HttpClient httpClient=new DefaultHttpClient();
				//连接超时
				httpClient.getParams().setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, 30000);
				//请求超时
				httpClient.getParams().setParameter(CoreConnectionPNames.SO_TIMEOUT, 30000);
				try {
					//执行请求
					HttpResponse httpResponse=httpClient.execute(httpPost);
					// 判断是够请求成功
					if(httpResponse.getStatusLine().getStatusCode()==HttpStatus.SC_OK){
						result = EntityUtils.toString(httpResponse.getEntity(), HTTP.UTF_8);
						return result;
				    }
				} catch (ClientProtocolException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			return null;
		}
}
