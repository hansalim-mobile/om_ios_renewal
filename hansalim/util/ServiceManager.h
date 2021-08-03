

#define kCommonKey @"common"
#define kParseErrCode @"parseErrCode"
#define kParseErrDesc @"parseErrDesc"

typedef void (^ServiceResponseBlock)(NSDictionary *response, NSError *error);
typedef void (^UserAgentBlock)(void);

@interface ServiceManager : NSObject

// user agent 값
@property (retain, nonatomic) NSString *defaultUsrAgent; // 변경 전 user agent
@property (retain, nonatomic) NSString *customUsrAgent; // 변경 후 user agent

// csrf 토큰 정보
@property (nonatomic, retain) NSString *csrfToken;

+ (ServiceManager*)sharedInstance;

// user agent 변경
-(void)changeUserAgent:(WKWebView *)curWebV
            completion:(UserAgentBlock)completion;

@end
