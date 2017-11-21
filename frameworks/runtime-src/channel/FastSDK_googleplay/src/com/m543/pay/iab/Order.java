package com.m543.pay.iab;

public class Order {

  private String payLoad;

  private String sku;

  public Order() {
  }
  
  public Order(String sku,String payLoad){
    this.sku=sku;
    this.payLoad=payLoad;
  }

  public String getPayLoad() {
    return payLoad;
  }

  public void setPayLoad(String payLoad) {
    this.payLoad = payLoad;
  }

  public String getSku() {
    return sku;
  }

  public void setSku(String sku) {
    this.sku = sku;
  }
  
 

}
