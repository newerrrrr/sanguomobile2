#ifndef nba_hero_iap_bridge_h
#define nba_hero_iap_bridge_h
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <sqlite3.h>

/**
 * in app purchase in objective-c
 *
 */
@interface  IapManager :NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    sqlite3 *database;
    NSString *databasePath;
}

+(IapManager*) sharedInstance;

+(void) purchase:(NSDictionary *)dictionary;

-(void)purchaseByOrderId:(NSString*)orderId AndProductId:(NSString*)productId AndLanguage:(NSString*)language;

-(void) requestProduct:(NSString*)productId;

-(BOOL) canMakePayments;

-(void) initStore;

-(void) releaseStore;

-(void) requestProUpgradeProductData:(NSString*)productId;

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

-(void) purchasedTransaction: (SKPaymentTransaction *)transaction;

-(void) completeTransaction: (SKPaymentTransaction *)transaction;

-(void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;

- (void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;

- (void) restoreTransaction: (SKPaymentTransaction *)transaction;

-(void) initDatabase;

-(BOOL)cacheOrderId:(NSString*)orderId AndReceiptData:(NSString*)receiptData;

-(void)asyncNotifyServerOrderId:(NSString*)orderId AndReceiptData:(NSString*)receiptData;

-(void)execSql:(NSString *)sql;

-(void)asyncNotifyServer;

-(BOOL)syncNotifyServerOrderId:(NSString*)orderId AndReceiptData:(NSString*)receiptData;

+(void)showLoadingDialog;

+(void)hideLoadingDialog;

-(void)showProgressDialog:(NSString*)text  ;

-(void)showProgressDialog:(NSString*)text  showBG:(BOOL) showBG;

-(void)hideProgressDialog:(int)delay;

+(void) clearResource;

@property (nonatomic, copy)NSString * orderId;

@property (nonatomic, copy)NSString * productId;

@property (nonatomic, copy) NSString* receiptData;

@property (nonatomic,retain)NSMutableData *receiveData;

@property(nonatomic,assign)BOOL isPaying;
@property (nonatomic, copy)NSString * language;

+(BOOL)canMakeRequest;

@end

extern void setNotifyUrl(const char * url);

#endif
