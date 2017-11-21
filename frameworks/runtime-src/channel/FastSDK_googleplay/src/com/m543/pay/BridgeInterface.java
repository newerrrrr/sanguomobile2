package com.m543.pay;

public interface BridgeInterface
{ 
	public void onLogin(final String userInfo,final int luaFunctionId);
	public void onShare(final String shareInfo,final int luaFunctionId);
}
