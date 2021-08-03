//
//  PushHepler
//
//

@interface PushHepler : NSObject

// link, push 연결 url
@property (strong, nonatomic) NSString *pushUrl;
// push ID
@property (strong, nonatomic) NSString *pushId;
// 앱실행 시 푸시 타이틀
@property (strong, nonatomic) NSString *pushTitle;
// 앱실행 시 푸시 메세지
@property (strong, nonatomic) NSString *pushMsg;

+(PushHepler*) getInstance;

// 링크 파라미터를 초기화
-(void)initPushUrl;

// payload로 부터 linkurl을 셋팅
-(void)setPushUrlFromApnsPayload:(NSDictionary *)launchOptions;

@end
