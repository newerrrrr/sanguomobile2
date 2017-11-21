//
//  YLApiObject.h
//  Api对象，包含所有接口和对象数据定义
//
//  Created by he on 16/11/7.
//  Copyright © 2016年 武汉点智科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
//初始化
typedef enum {
    YLINITSuccess                 = 2000,    //初始化成功
    YLINITServerError             = 6001,    //服务器正在维护
    YLINITNetError                = 7,       //网络异常
    
    YLINITOtherError              = 0,       //其他错误
    
} YL_INIT_ERROR;

//登录
typedef enum {
    YLLOGINFail                 = 0,    //登录失败
    YLLOGINSuccess              = 1,    //登录成功
    YLLOGINServerError          = 2,    //服务器正在维护
    YLLOGINRETURN               = 3,    //返回游戏
    YLLOGINNetError             = 7,       //网络异常
    
    YLLOGINOtherError           = 0,       //其他错误
    
} YL_Login_ERROR;
//支付
typedef enum {
    YLTreatedOrderSuccess         = 1,        //支付成功
    YLTreatedOrderFail            = 2,        //支付失败
    YLTreatedOrderPaying          = 3,        //正在支付中
    YLTreatedOrderCancel          = 4,        //取消支付
    YLTreatedOrderCloseMenu       = 5,        //关闭支付界面
    YLTreatedOrderNoModeList      = 6,        //服务端支付信息列表为空
    YLTreatedOrderNetError        = 7,        //网络异常
    
    YLTreatedOrderInvalidProduct  = 11,        //内购，苹果后台没有对应的产品ID或产品ID无效
    YLTreatedOrderPriceError      = 12,        //内购，订单对应的金额和苹果后台配置的金额不一致
    YLTreatedOrderReceiptFail     = 13,        //内购，凭证验证失败或者没有通知到游戏服务器
    YLTreatedOrderUnKnow          = 14,        //支付结果未知
    YLTreatedOrderOtherError      = 0,        //其他错误
    
} YL_TreatedOrder_ERROR;

/**
 *  采集点类型
 */
typedef enum{
    YL_LoginColl = 1 /**< 登录 */,
    YL_LevelUpColl = 2 /**< 升级 */,
    YL_CreateRoleColl   = 3 /**< 创建角色 */,
    YL_RechargeColl   = 4 /**< 充值 */,
    YL_ExitColl   = 5 /**< 退出 */,
}YL_CollType;

/**
 *  类型
 */
typedef enum{
    YL_App = 0 /**<  */,
    YL_Cat = 1 /**<  */,
    YL_Ball  = 2 /**<  */,
    YL_UP  = 3 /**<  */,
    YL_PTB  = 4 /**<  */,
    YL_Dog  = 5 /**<  */,
}YL_Type;

#pragma mark - GameAppInfo
/*! @brief cp调起登录界面的结构体
 *
 */
@interface GameAppInfo : NSObject

@property (nonatomic, copy) NSString *gameId;//应用id
@property (nonatomic, copy) NSString *gameName;//应用名称
@property (nonatomic, copy) NSString *gameAppId;//应用Appid
@property (nonatomic, copy) NSString *promoteId;//推广id
@property (nonatomic, copy) NSString *promoteAccount;//推广名称
@property (nonatomic, copy) NSString *is_test; //是否测试，0 正式（提审）版 |  1 测试版
@property (nonatomic, copy) NSString *MD5key;//不用传，可忽略
@property (nonatomic, copy) NSString *appkey;//不用传，可忽略

@end

#pragma mark - OrderInfo
/*! @brief 发起支付下单的结构体
 *
 */
@interface OrderInfo : NSObject

@property (nonatomic, assign) int goodsPrice;//商品价格，单位为分
@property (nonatomic, copy) NSString *goodsName;//商品名称
@property (nonatomic, copy) NSString *goodsDesc;//商品描述
@property (nonatomic, copy) NSString *productId;//虚拟商品在APP Store中的ID
@property (nonatomic, copy) NSString *extendInfo;//cp自定义的透传字段，此字段会透传到游戏服务器
@property (nonatomic, copy) NSString *player_server;//玩家所在服务器
@property (nonatomic, copy) NSString *player_role;// 玩家角色信息
@property (nonatomic, copy) NSString *cp_trade_no;//CP订单号
@end
