//
//  PushHepler
//

#import "PushHepler.h"

@implementation PushHepler

+(PushHepler*)getInstance
{
    static PushHepler* manager;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if(manager == nil) {
            manager = [[PushHepler alloc] init];
        }
    });
    return manager;
}

// 링크 파라미터를 초기화
-(void)initPushUrl
{
    self.pushUrl = nil;
    self.pushId = nil;
}

// payload로 부터 linkurl을 셋팅
-(void)setPushUrlFromApnsPayload:(NSDictionary *)launchOptions
{
    // link url 셋팅
    self.pushUrl = launchOptions[@"pushUrl"];
    self.pushId = launchOptions[@"pushId"];
    // alert 정보 셋팅
    NSDictionary *alertInfo = launchOptions[@"aps"][@"alert"];
    if(alertInfo && [alertInfo isKindOfClass:[NSDictionary class]]) {
        self.pushTitle = alertInfo[@"title"];
        self.pushMsg = alertInfo[@"body"];
    }
}

@end
