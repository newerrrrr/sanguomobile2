#include "IapManager.h"
#include "../../forLua/cToolsForLua.h"

@implementation IapManager

static char s_Notify_URL[512] = {0};

static IapManager* _sharedInstance=nil;

+(IapManager*)sharedInstance
{
    @synchronized([IapManager class])
    {
        if(!_sharedInstance)
        {
            _sharedInstance=[[self alloc]init];
        }
        return _sharedInstance;
    }
    return nil;
}

+(id)alloc
{
    @synchronized([IapManager class])
    {
        NSAssert(_sharedInstance==nil, @"Attempted to allocate a second instance of a singleton.\n");
        _sharedInstance=[super alloc];
        _sharedInstance.isPaying=NO;
        return _sharedInstance;
    }
    return nil;
}

-(id)init
{
    self=[super init];
    [self initDatabase];
    return self;
}

-(void) initStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)releaseStore
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
+(void) purchase:(NSDictionary *)dictionary
{
    NSLog(@"-------call purchase------");
    
    NSString *orderId=[dictionary objectForKey:@"orderId"];
    
    NSString *productId=[dictionary objectForKey:@"productId"];
    
    NSString *language=[dictionary objectForKey:@"language"];

    IapManager* instance=[IapManager sharedInstance];

    [instance initStore];
    
    if (![instance isPaying])
    {
      instance.isPaying=YES;
        
      [instance purchaseByOrderId:orderId AndProductId:productId AndLanguage:language];
    }
    else
    {
        NSLog(@"in app purchase is paying");
    }
}
+(BOOL) canMakeRequest
{
    IapManager* instance=[IapManager sharedInstance];
    return !instance.isPaying;
}


-(BOOL) canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

-(void) purchaseByOrderId:(NSString *)orderId AndProductId:(NSString *)productId AndLanguage:(NSString *)language
{
    [[NSUserDefaults standardUserDefaults] setObject:orderId forKey:@"cacheOrderId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.orderId=[orderId retain];
    self.language=[language retain];
    [self requestProduct:productId];
}
-(void) requestProduct:(NSString *)productId
{
    NSLog(@"------start to request product------\n");
    
    if([self canMakePayments])
    {
        self.productId=[productId retain];
        
        NSArray *product=[[NSArray alloc] initWithObjects:productId, nil];
        
        NSSet *products=[NSSet setWithArray:product];
        
        SKProductsRequest *request=[[SKProductsRequest alloc]initWithProductIdentifiers:products];
        
        [request autorelease];
        
        request.delegate=self;
        
        [request start];
        
        [product release];
    }
    else
    {
        self.isPaying=NO;
        
        [self hideProgressDialog:0];
        
        NSString *title=@"儲值成功";//NSLocalizedString(@"儲值成功",nil);
        if([self.language isEqualToString:@"zhcn"])
        {
            title=@"充值成功";
        }
        
        NSString *message=@"很遺憾，購買失敗";//NSLocalizedString(@"purchase_bank_error",nil);
        if([self.language isEqualToString:@"zhcn"])
        {
            message=@"很遗憾，购买失败";
        }

        
        NSString *cancelText=@"關閉";//NSLocalizedString(@"關閉",nil);
        
        if([self.language isEqualToString:@"zhcn"])
        {
            cancelText=@"关闭";
        }
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:cancelText
                                                  otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];

    }
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSLog(@"------request product  callback------\n");
    
    NSArray *products=response.products;
    
    if([products count]>0)
    {
        SKProduct *product=[products objectAtIndex:0];
        SKPayment *payment=[SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        self.isPaying=NO;
        
        [self hideProgressDialog:0];

        NSString *title=@"提示";//NSLocalizedString(@"儲值成功",nil);
        if([self.language isEqualToString:@"zhcn"])
        {
            title=@"提示";
        }
        
        NSString *message=@"很遺憾，購買失敗";//NSLocalizedString(@"purchase_no_product_error",nil);
        if([self.language isEqualToString:@"zhcn"])
        {
            message=@"很遗憾，购买失败";
        }
        
        
        NSString *cancelText=@"關閉";//NSLocalizedString(@"關閉",nil);
        
        if([self.language isEqualToString:@"zhcn"])
        {
            cancelText=@"关闭";
        }
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:cancelText
                                                  otherButtonTitles:nil];
        
        [alerView show];
        [alerView release];
    }
}


-(void) purchasedTransaction: (SKPaymentTransaction *)transaction
{

    NSLog(@"-----Purchased Transaction----\n");

    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    
    [transactions release];
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{

    NSLog(@"-----paymentQueue updatedTransactions----\n");

    for (SKPaymentTransaction *transaction in transactions)
    {
        //purchase success
        if(transaction.transactionState==SKPaymentTransactionStatePurchased)
        {
            NSLog(@"------SKPaymentTransactionStatePurchased-------\n");
            
            [self completeTransaction:transaction];
        
        }
        //purchase failed
        else if(transaction.transactionState==SKPaymentTransactionStateFailed)
        {
            NSLog(@"------payment error:%@------\n", transaction.error);
            
            [self failedTransaction:transaction];

        }
        //purchase in progress
        else if(transaction.transactionState==SKPaymentTransactionStatePurchasing)
        {
            NSLog(@"------SKPaymentTransactionStatePurchasing-------\n");
        }
        else if(transaction.transactionState==SKPaymentTransactionStateRestored)
        {
            NSLog(@"------SKPaymentTransactionStateRestored-------\n");
        }
       
    }
}

//complete Transaction ,now we post data to server
- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----completeTransaction--------\n");
    
    NSString *result=[[transaction transactionReceipt] base64Encoding];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    NSString *orderId=[[NSUserDefaults standardUserDefaults] objectForKey:@"cacheOrderId"];

    NSLog(@"cacheOrderId=%@",orderId);

    self.orderId=orderId;

    [self asyncNotifyServerOrderId:[self orderId] AndReceiptData:result];
        
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"------failedTransaction------\n");
    
    self.isPaying=NO;
    
    [self hideProgressDialog:0];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    
    NSString *title=@"提示";//NSLocalizedString(@"儲值成功",nil);
    NSString *message=@"很遺憾，購買失敗";//NSLocalizedString(@"purchase_failed",nil);
    if([self.language isEqualToString:@"zhcn"])
    {
        message=@"很遗憾，购买失败";
    }
    
    
    NSString *cancelText=@"關閉";//NSLocalizedString(@"關閉",nil);
    
    if([self.language isEqualToString:@"zhcn"])
    {
        cancelText=@"关闭";
    }
    
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:cancelText
                                              otherButtonTitles:nil];
    [alerView show];
    [alerView release];

}


-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{
    NSLog(@"------paymentQueueRestoreCompletedTransactionsFinished------\n");
}



- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"------Restore transaction------\n");
}



-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"------Payment Queue------\n");
}


-(void) requestProUpgradeProductData:(NSString *)productId
{
   
    NSLog(@"------requestProUpgradeProductData------\n");
    
    NSSet *productIdentifiers = [NSSet setWithObject:productId];
    
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    
    productsRequest.delegate = self;
    
    [productsRequest start];
    
    [productsRequest autorelease];
}



- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"------Show fail message------\n");
    
    self.isPaying=NO;
    
    [self hideProgressDialog:0];
    
    NSString *title=@"提示";//NSLocalizedString(@"提示",nil);
    NSString *message=[error localizedDescription];
    NSString *cancelText=@"關閉";//NSLocalizedString(@"關閉",nil);
    
    if([self.language isEqualToString:@"zhcn"])
    {
        cancelText=@"关闭";
    }
    
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:cancelText
                                              otherButtonTitles:nil];
    [alerView show];
    [alerView release];

}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"------Request finished------\n");
    
    [self hideProgressDialog:0];
    
}
-(void) initDatabase
{

    
    NSString *docsDir=nil;
    
    NSArray *dirPaths=nil;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"iapCache.db"]];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if ([filemanager fileExistsAtPath:databasePath] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &database)==SQLITE_OK)
        {
            NSLog(@"open database ok\n");
            
            char *errmsg;
            
            const char *createsql = "CREATE TABLE IF NOT EXISTS iap_cache(id INTEGER PRIMARY KEY AUTOINCREMENT, orderId TEXT,receiptData TEXT)";
            
            if (sqlite3_exec(database, createsql, NULL, NULL, &errmsg)!=SQLITE_OK)
            {
                NSLog(@"create table failed.\n");
            }
            else
            {
               NSLog(@"create table success\n");
            }
        }
        else
        {
            NSLog(@"create or open failed.\n");
            
            sqlite3_close(database);
        }
    }
    else
    {
        NSLog(@"database file exists at path %@\n",databasePath);
    }

}

-(BOOL)cacheOrderId:(NSString*)orderId AndReceiptData:(NSString*)receiptData
{

    const char *dbPath=[databasePath UTF8String];
    
    if(sqlite3_open(dbPath, &database)==SQLITE_OK)
    {
        NSLog(@"open database ok\n");
        
        sqlite3_stmt *statement;
        
        NSString *sql=[NSString stringWithFormat:@"insert into iap_cache(orderId,receiptData) VALUES(\"%@\",\"%@\")",orderId,receiptData];
        
        const char *insertStatement=[sql UTF8String];
        
        sqlite3_prepare_v2(database, insertStatement, -1, &statement, NULL);
        
        bool flag=YES;
        
        if(sqlite3_step(statement)==SQLITE_DONE)
        {
            NSLog(@"save data success\n");
            
            flag=YES;
        }
        else
        {
            NSLog(@"save data failed\n");
            
            flag=NO;
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
        
        return flag;
    }
    else
    {
        NSLog(@"open database failed\n");
        
        return NO;
    }
}
-(void)execSql:(NSString *)sql
{
    const char *dbPath=[databasePath UTF8String];
    
    if(sqlite3_open(dbPath, &database)==SQLITE_OK)
    {
        char *err;
        
        if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            NSLog(@"Failure database operation data，%s",err);
            
        }
        else
        {
            NSLog(@"sql=%@",sql);
        }
        sqlite3_close(database);
    }
}
-(void)asyncNotifyServer
{

    //async handle cache order
    NSLog(@"-----------------------now prepare to sync-----------------------");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *dbPath=[databasePath UTF8String];
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSMutableArray *records=nil;
            
            NSLog(@"open database ok\n");
            
            sqlite3_stmt *statement;
            
            NSString *sql=@"select * from iap_cache";
            
            const char *queryStatement=[sql UTF8String];
            
            if(sqlite3_prepare_v2(database, queryStatement, -1, &statement, nil)==SQLITE_OK)
            {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    if(records==nil)
                    {
                        records=[[NSMutableArray alloc]init];
                    }
                    //index from 0
                    char *orderId = (char*)sqlite3_column_text(statement, 1);
                    
                    NSString *nsOrderId = [[NSString alloc]initWithUTF8String:orderId];
                    
                    char* receiptData = (char*)sqlite3_column_text(statement, 2);
                    
                    NSString *nsReceiptData = [[NSString alloc]initWithUTF8String:receiptData];
                    
                    NSDictionary *record=[NSDictionary dictionaryWithObjectsAndKeys:nsOrderId ,@"orderId",nsReceiptData,@"receiptData",nil];
                    
                    [records addObject:record];
                    
                    NSLog(@"orderId:%@\n;receiptData=%@",nsOrderId,nsReceiptData);
                }
            }
            else
            {
                NSLog(@"select data failed\n");
            }
            sqlite3_close(database);
            
            if(records!=nil)
            {
                NSLog(@"------start to async data------\n");
                
                for(int i=0;i<[records count];i++)
                {
                    
                    NSDictionary *record=[records objectAtIndex:i];
                    
                    NSString *nsOrderId = [record objectForKey:@"orderId"];
                    
                    NSString *nsReceiptData = [record objectForKey:@"receiptData"];
                    
                    if([self syncNotifyServerOrderId:nsOrderId AndReceiptData:nsReceiptData])
                    {
                        
                         NSString *deleteSql = [NSString stringWithFormat:@"delete from iap_cache where orderId='%@'",nsOrderId];
                        
                        [self execSql:deleteSql];
                    }
                }
                [records release];
            }else{
                 NSLog(@"------no data to sync ------\n");
            }
        }
        else
        {
            NSLog(@"open database failed\n");
            
        }

    });
    
}
-(BOOL)syncNotifyServerOrderId:(NSString*)orderId AndReceiptData:(NSString*)receiptData
{
    
    NSLog(@"-----syncNotifyServerOrderId AndReceiptData------\n");
    
    NSString *notifyUrl=[NSString stringWithUTF8String:s_Notify_URL];
    
    NSString *data = [NSString stringWithFormat:@"orderId=%@&receipt-data=%@",orderId,receiptData];
    
    self.receiptData=[receiptData retain];
    
    NSData *postData = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSURL *url=[NSURL URLWithString:notifyUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSData *received=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError *error=nil;
    
    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves  error:&error];
    
    if(json==nil)
    {
        NSLog(@"json error=%@",error);
        
        return NO;
    }
    
    NSString *status=[json objectForKey:@"status"];

    if([@"success" isEqualToString:status])
    {
        return YES;
    }
    else
    {
        NSString *message=[json objectForKey:@"message"];
        
        NSLog(@"message=%@", [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        
        return NO;
    }
}
/**
 *post data to payment server
 *
 (*/
-(void)asyncNotifyServerOrderId:(NSString*)orderId AndReceiptData:(NSString*)receiptData
{
    
    NSLog(@"-----notifyServer------\n");
    
    NSString *tips=NSLocalizedString(@"processing_data", nil);
    
    [self showProgressDialog:tips showBG:true];
    
    NSString *notifyUrl=[NSString stringWithUTF8String:s_Notify_URL];
    
    NSLog(@"notifyUrl=%@",notifyUrl);
    
    NSString *data = [NSString stringWithFormat:@"orderId=%@&receipt-data=%@",orderId,receiptData];
    
    NSLog(@"data=%@",data);
    
    self.receiptData=[receiptData retain];
    
    NSData *postData = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setURL:[NSURL URLWithString:notifyUrl]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    NSURLConnection *conn=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    [conn start];
    
    [conn autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"----connection didReceiveResponse-----");
    
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    
    NSLog(@"statusCode=%d",[res statusCode]);

    if([res statusCode]==200)
    {
        self.receiveData=[NSMutableData data];
    }
    else
    {
        [self cacheOrderId:self.orderId AndReceiptData:self.receiptData];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"----connection didReceiveData----- data=%@",data);
    
    if(self.receiveData!=nil)
    {
      [self.receiveData appendData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"----connectionDidFinishLoading-----");
    
    self.isPaying=NO;
    
    [self hideProgressDialog:0];
    
    if(self.receiveData!=nil)
    {
    
        NSError *error=nil;
    
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:self.receiveData options:NSJSONReadingMutableLeaves  error:&error];
    
        if(json==nil)
        {
            NSLog(@"json error=%@",error);
            [self cacheOrderId:self.orderId AndReceiptData:self.receiptData];
            return ;
        }
    
        NSString *status=[json objectForKey:@"status"];
        
        NSString *message=[json objectForKey:@"message"];
        
        NSString *msg=[message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if([@"failure" isEqualToString:status])
        {

            NSLog(@"message=%@",msg);
            [self cacheOrderId:self.orderId AndReceiptData:self.receiptData];
            [self asyncNotifyServer];
        }


        NSString *title=@"提示";//NSLocalizedString(@"提示",nil);
        
        NSString *cancelText=@"關閉";//NSLocalizedString(@"關閉",nil);
        
        if([self.language isEqualToString:@"zhcn"])
        {
            cancelText=@"关闭";
        }
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:cancelText
                                                  otherButtonTitles:nil];
        [alerView show];
        [alerView release];

   }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection error=%@",[error localizedDescription]);
    
    self.isPaying=NO;
    
    [self hideProgressDialog:0];
    
    if (self.orderId!=nil&&self.receiptData!=nil)
    {
      [self cacheOrderId:self.orderId AndReceiptData:self.receiptData];
    }
    
}
+(void)showLoadingDialog
{
    
    NSString *msg=@"正在儲值，請稍候...";//NSLocalizedString(@"正在儲值，請稍候...", nil);
    
    [[IapManager sharedInstance] showProgressDialog:msg showBG: YES];
    
}
+(void)hideLoadingDialog
{
    [[IapManager sharedInstance] hideProgressDialog:0];
}

-(void)showProgressDialog:(NSString*)text
{
    [self showProgressDialog:text showBG: YES ];
}

-(void)showProgressDialog:(NSString*)text  showBG:(BOOL) showBG
{
    cToolsForLua::showAsynchronousBox();
}

-(void)hideProgressDialog:(int)delay
{
    cToolsForLua::hideAsynchronousBox();
}

/**
 * when progressDialog hide,callback this function
 */
+(void) clearResource
{
    if(_sharedInstance!=nil)
    {
        [_sharedInstance releaseStore];
        [[_sharedInstance orderId]release];
        [[_sharedInstance productId]release];
        [[_sharedInstance receiveData]release];
        [[_sharedInstance receiveData]release];
    }
}
@end


void setNotifyUrl(const char * url)
{
	strcpy(s_Notify_URL, url);
}



