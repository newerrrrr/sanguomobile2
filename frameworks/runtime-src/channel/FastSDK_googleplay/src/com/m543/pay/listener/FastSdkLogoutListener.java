package com.m543.pay.listener;

public interface FastSdkLogoutListener {	
	public void onSuccess(String msg,Object customParams);
	public void onFailure(String msg,Object customParams);
	public void onCancel();
}

