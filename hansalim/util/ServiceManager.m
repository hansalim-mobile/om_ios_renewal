

#import "ServiceManager.h"

@interface ServiceManager () {
}

@end

@implementation ServiceManager

+ (ServiceManager*)sharedInstance
{
    static ServiceManager* service;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if(service == nil) {
            service = [[ServiceManager alloc] init];
        }
    });
    return service;
}

// user agent 변경
-(void)changeUserAgent:(WKWebView *)curWebV completion:(UserAgentBlock)completion {
    // user agent 값을 수정한 뒤 웹을 로드한다.
    UIWebView *dummyWV = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *defAgent = [dummyWV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    self.customUsrAgent = [NSString stringWithFormat:@"%@ %@", defAgent, vAgentNm];
    curWebV.customUserAgent = self.customUsrAgent;
    [curWebV evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *result, NSError *error){
        NSLog(@"#################### USER AGENT 정보 시작 ####################");
        NSLog(@"변경 useragent : %@", result);
        NSLog(@"#################### USER AGENT 정보 끝 ####################");
        if(completion) {
            completion();
        }
    }];
}


@end
