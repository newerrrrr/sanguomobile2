//
//  YLApi.h
//  所有Api接口
//
//  Created by he on 16/10/25.
//  Copyright © 2016年 武汉点智科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YLApiObject.h"

typedef void(^CompletionBlock)(NSDictionary *resultDic);



@interface YLApi : NSObject{
    
}
/**
漏单回调
*/
@property (nonatomic, strong) CompletionBlock YL_paySuccess;

/**
 *  创建支付单例服务
 *
 *  @return 返回单例对象
 */
+ (YLApi *) YL_sharedInstance;
/**
 *  登录接口
 *
 *  @param gameappinfo    应用信息
 *  @param superview      调用登录的控制器view，使用self.view
 *  @param completion     登录结果回调Block
 */
-(void) YL_addLoginView:(id)superview gameInfo:(GameAppInfo *)gameappinfo completion:(CompletionBlock)completion;
/**
 *  登录接口
 *
 *  @param superview      调用登录的控制器view，使用self.view
 *  @param completion     登录结果回调Block
 */
-(void) YL_addLoginView:(id)superview completion:(CompletionBlock)completion;
/**
 
一键登陆接口
 @param completion 登录结果回调Block
 */
-(void) YL_addWithOutLogin:(CompletionBlock)completion;
/**
 *  一键登陆接口
 *
 *  @return gameappinfo    应用信息
 */
-(void) YL_addWithOutLogin:(GameAppInfo*)gameappinfo completion:(CompletionBlock)completion;

/**
 *  退出接口
 *
 *  @param completion     退出回调Block
 */
-(void) YL_exitLogin:(CompletionBlock)exitBlock;

/**
 *  支付接口
 *
 *  @param orderStr       订单信息
 *  @param completionBlock 支付结果回调Block
 */
-(void) YL_pay:(OrderInfo *)orderStr
completionBlock:(CompletionBlock)completionBlock;
/**
 *  注销接口
 */
-(void) YL_mcLogout;

/**
 *  悬浮窗
 */
-(void)displayIcon;

/**
 移除
 */
- (void)removeIcon;
/**
 初始化SDK(注：使用这个方法初始化，登录的时候就要调用传入gameappinfo的登录方法)

 @param gameId gameId
 @param completion completion
 */
- (void)YL_setYLApi:(NSString *)gameId completion:(CompletionBlock)completion;

/**
 初始化游戏SDK,统计key
 
 @param gameappinfo 游戏相关参数
 @param trackKey 统计key
 @param completion completion
 */
- (void)YL_setYLApiWithInfo:(GameAppInfo *)gameappinfo trackKey:(NSString *)trackKey completion:(CompletionBlock)completion;

/**
 进入前台验证订单状态
 */
+(void) YL_ExperimentalWX;
#pragma mark - 创角
- (void)YL_createRoleSuccess;
#pragma mark - cpl 玩家游戏信息上报
/**
 玩家游戏信息上报
 
 @param type 上报触发点：1 登录 | 2 升级 | 3 创建角色 | 4 充值 | 5 退出   【必传参数】
 @param uid CP端玩家uid
 @param server_name 区服名【必传参数】
 @param player_name 角色名【必传参数】
 @param player_level 角色等级【必传参数】
 @param chargeSuccess 角色创建时间戳(秒)【必传参数】
 */
- (void)YL_cplPlayerInfo:(YL_CollType)type uid:(NSString *)uid server_name:(NSString *)server_name player_name:(NSString *)player_name player_level:(NSString *)player_level ctime:(NSString *)ctime;
@end
