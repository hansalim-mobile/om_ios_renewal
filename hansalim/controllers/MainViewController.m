//
//  MainViewController.m
//  hansalim
//
//  Created by marco on 2021/06/16.
//
#import "MainViewController.h"
#import "ServiceManager.h"
#import "HybridAdapter.h"

@interface MainViewController ()<SignInDelegate> {
    AppDelegate *appDelegate;
}
@end

@implementation MainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    appDelegate.delegate = self;

    self.createdWKWebViews = [NSMutableArray array];
    [self createMainWebView];
    
    // 푸시 진입 시 처리
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPush:) name:kApnsNoti object:nil];
    // 앱 백그라운드 이동시 처리
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:kWillResignActive object:nil];
}

// 쿠키 적용 가이드 링크
// https://taesulee.tistory.com/6
//  https://itstudentstudy.tistory.com/113


- (void)createMainWebView {

    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    webViewConfig.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    WKUserScript* webReturnScript = [[WKUserScript alloc] initWithSource:@"Hybrid.thirdParty.responseCertificateApp()" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];//v3.0.5 정기충전 미등록 버그 해결
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    
    [userContentController addUserScript:webReturnScript];//v3.0.5 정기충전 미등록 버그 해결
    [userContentController addScriptMessageHandler:self name:@"excuteBarcode"];
    [userContentController addScriptMessageHandler:self name:@"getDeviceId"];
    [userContentController addScriptMessageHandler:self name:@"getSessionId"];
    [userContentController addScriptMessageHandler:self name:@"setSessionId"];
    [userContentController addScriptMessageHandler:self name:@"externalBrowser"];
    webViewConfig.userContentController = userContentController;
    
    // sessiont cookies remove
    NSSet* nSet= [NSSet setWithArray:@[WKWebsiteDataTypeSessionStorage]];
    NSDate *nDate=[NSDate dateWithTimeIntervalSince1970:0];
    [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:nSet modifiedSince:nDate completionHandler:^{
        NSLog(@"WKWebsiteDataTypeSessionStorage removed");
    }];

    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    [self.createdWKWebViews addObject:wkWebView];

    [self setWebVSettingDelegate:[self curWebView]];
    [self.wkContainer addSubview:[self curWebView]];
    [HybridAdapter setWKWebView:[self curWebView]];
    [[self curWebView] fill_parent];

    // user agent 값을 수정한 뒤 웹을 로드한다.
    [[ServiceManager sharedInstance] changeUserAgent:[self curWebView] completion:^(void) {
        // user agent 수정 후 최초 페이지를 로드한다.
        [self startFirstLoad];
    }];

}


#pragma mark - Push

// 푸시 처리
-(void)showPush:(NSNotification *)notification {
    NSLog(@"showPush");
    // 만약 child 웹뷰가 있다면 모두 삭제한다.
    [self removeAllChildWebView];
    
    
//    if([PushHepler getInstance].imgUrl.length > 0) {
//        NSLog(@"imgUrl URL [%@]", [PushHepler getInstance].imgUrl);
//    }
    
    // push url 로드
    if([PushHepler getInstance].pushUrl.length > 0) {
        NSURL *loadUrl = [NSURL URLWithString:[PushHepler getInstance].pushUrl];
        if([[UIApplication sharedApplication] canOpenURL:loadUrl]) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loadUrl];
            [[self curWebView] loadRequest:request];
        }
    }
    if([PushHepler getInstance].pushId.length > 0) {
        NSURL *pushId = [NSURL URLWithString:[PushHepler getInstance].pushId];
        JSONRequestDictionary *query = [[JSONRequestDictionary alloc] init];
        NSString *url = [NSString stringWithFormat:@"%@%@&deviceRegId=%@",PUSH_READ, pushId, [[NSUserDefaults standardUserDefaults] objectForKey:@"_token"]];
        [query sendAsynchronousRequest:url
                            completion:^(NSDictionary *response, NSError *error) {
                            } success:^(NSDictionary *response) {
                                NSLog(@"showPush >> JSONRequestDictionary >> PUSH_READ >> Success !!");
                            } fail:^(NSError *error) {
                            }];
    }
}


-(void)willResignActive:(NSNotification *)notification {
    NSLog(@"willResignActive func in !!! ");

}



#pragma mark - 웹뷰 관련

// 최초 시작
-(void)startFirstLoad {
    // 만약 link로 들어온 경우 param 값이 있는지 확인하고 있다면 param을 로드하고 아니면 홈페이지로 이동한다.
    NSString *pushUrl = [PushHepler getInstance].pushUrl;
    if(pushUrl.length>0 && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pushUrl]]) {
        // link url 로드

        NSURL *loadUrl = [NSURL URLWithString:pushUrl];
        if([[UIApplication sharedApplication] canOpenURL:loadUrl]) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loadUrl];
            [[self curWebView] loadRequest:request];
        }
        // 로드 후 초기화 한다.
        [[PushHepler getInstance] initPushUrl];
    }
    // 링크값이 없는 경우 홈페이지를 로드한다.
    else {
        //NSURL *loadUrl = [NSURL URLWithString:@"https://shop.hansalim.or.kr/shopping/CrossCert/webtoapp/sample.html"];//v3.0.4 PARK JIHYE
        NSURL *loadUrl = [NSURL URLWithString:HANSALIM_MAIN];
        if([[UIApplication sharedApplication] canOpenURL:loadUrl]) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loadUrl];
            [[self curWebView] loadRequest:request];
        }
    }
}


// wkwebview의 delegate와 settring 처리 공통
// 필요시 delegate 구현
-(void)setWebVSettingDelegate:(WKWebView *)webV {
    // 웹뷰 탭 시 보안키패드 내리기 처리
    webV.navigationDelegate = self;
    webV.UIDelegate = self;
}



// 현재 웹뷰를 가져온다.
-(WKWebView *)curWebView {
    if(self.createdWKWebViews.count==0)
        return nil;
    else
        return [self.createdWKWebViews objectAtIndex:(self.createdWKWebViews.count-1)];
}

// 생성된 웹뷰를 추가한다.
-(void)addChildWebView:(WKWebView *)newWebView {
    CGFloat vHeight = self.wkContainer.frame.size.height;

    UIView *pView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, vHeight)];
    [pView setBackgroundColor:UIColor.clearColor];
    [self.wkContainer addSubview:pView];

    UIView *sView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, vHeight)];
    [sView setBackgroundColor:UIColor.blackColor];
    [sView setAlpha:0.2];
    [pView addSubview:sView];
    
    newWebView.frame = CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, vHeight);
    [self setWebVSettingDelegate:newWebView];
    [pView addSubview:newWebView];
    
    [self.createdWKWebViews addObject:newWebView];
    
    newWebView.alpha = 0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        newWebView.frame = CGRectMake(0, 0, SCREENWIDTH, vHeight);
        newWebView.alpha = 1;
        [sView setAlpha:1.0];
    } completion:^(BOOL finished) {
    }];
}


// 모든 웹뷰를 삭제한다.
-(void)removeAllWebView {
    // 만약 child 웹뷰가 있다면 모두 삭제하고 base 웹뷰에 delegate 셋팅을 한다.
    __block NSArray *webArr = self.createdWKWebViews;
    for (WKWebView *child in webArr) {
//        [child removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
        [child.superview removeFromSuperview];
    }
    [self.createdWKWebViews removeAllObjects];
}

// 모든 child 웹뷰를 삭제한다.
-(void)removeAllChildWebView {
    // 만약 child 웹뷰가 있다면 모두 삭제하고 base 웹뷰에 delegate 셋팅을 한다.
    __block NSArray *webArr = self.createdWKWebViews;
    NSInteger lastIndex = webArr.count-1;
    for (NSInteger i=0; i<lastIndex; i++) {
        [self removeWebViewAtIndex:lastIndex-i];
    }
}

// 해당 인덱스의 웹뷰를 삭제하고 하위 웹뷰에 delegate를 연결한다.
-(void)removeWebViewAtIndex:(NSInteger)targetIndex {
    // base 웹은 삭제 할수 없다.
    if(targetIndex==0) return;
    WKWebView *child = [self.createdWKWebViews objectAtIndex:targetIndex];
//    [child removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    // 해당뷰를 삭제
    [child.superview removeFromSuperview];
    // 배열에서 인스턴스 삭제
    [self.createdWKWebViews removeObject:child];
    // 이전 WkWebView Delegate와 Setting 처리
    WKWebView *curView = [self.createdWKWebViews objectAtIndex:[self.createdWKWebViews count]-1];
    [self setWebVSettingDelegate:(WKWebView *)curView];
}

// 제일 상단의 child 웹뷰를 애니메이션과 함께 삭제한다.
-(void)removeWebViewAfterAnimate:(WKWebView *)removeView {
    NSInteger removeIndex = [self.createdWKWebViews indexOfObject:removeView];
    
    UIView *topShadowView;
    for (UIView *sibling in removeView.superview.subviews) {
        if(sibling!=removeView) {
            topShadowView = sibling;
            break;
        }
    }
    
    if(topShadowView) {
        removeView.alpha = 1;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             removeView.alpha = 0;
                             removeView.frame = CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, [self curWebView].frame.size.height);
                             [topShadowView setAlpha:0];
                         } completion:^(BOOL finished) {
                             [self removeWebViewAtIndex:removeIndex];
                         }];
    } else {
        [self removeWebViewAtIndex:removeIndex];
    }
}





#pragma mark - WKScriptMessageHandler


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@">>>>>>> WKWebView userContentController bridge name : %@", message.name);

    self.tempJsonTxt = message.body; // 파라미터 json 저장
    NSLog(@">>>>>>> tempJsonTxt : %@", _tempJsonTxt);
    
    // 파라미터 dic에 셋팅
    NSDictionary *bridInfo = nil;
//    if(self.tempJsonTxt.length>0) {
        bridInfo = [Util jsonStrToDic:self.tempJsonTxt];
//    }

    if([message.name isEqualToString:@"excuteBarcode"]) { // 바코드 뷰 컨트롤러 호출
        self.tempCallbackFunc = bridInfo[@"callbackFunc"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        BarcodeViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"barcode"];
        view.delegate = self;
        [self presentViewController:view animated:true completion:nil];
    }
    else if([message.name isEqualToString:@"getDeviceId"]) { // 디바이스 아이디 요청
        NSString * nowtoken = [[NSUserDefaults standardUserDefaults] objectForKey:@"_token"];
        NSDictionary *callbackInfo = @{
                                       @"token":AvoidNil(nowtoken)
                                       };
        [self callJavaScript:bridInfo[@"callbackFunc"] paramDic:callbackInfo];
    }
    else if([message.name isEqualToString:@"getSessionId"]) { // 저장해둔 세션 아이디 요청
        NSString * sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"_session"];
        NSDictionary *callbackInfo = @{
                                       @"session":AvoidNil(sessionId)
                                       };
        [self callJavaScript:bridInfo[@"callbackFunc"] paramDic:callbackInfo];
    }
    else if([message.name isEqualToString:@"setSessionId"]) { // 세션 아이디 저장
        NSString *session = bridInfo[@"session"];
        [[NSUserDefaults standardUserDefaults] setObject:session forKey:@"_session"];
        
//        [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull result) {
//            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:result requiringSecureCoding:YES error:nil];
//            [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"saved_cookies"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }];
    }
    else if([message.name isEqualToString:@"externalBrowser"]) {
        NSString *url = bridInfo[@"url"];
        
        NSURL* linkUrl = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:linkUrl options:@{} completionHandler:^(BOOL success) {
            NSLog(@"%@ [Opened url] %@ !!!", linkUrl, success ? @"Success" : @"Fail");
        }];
    }
}


// 자바스크립트 공통 함수
-(void)callJavaScript:(NSString *)funcNm paramDic:(NSDictionary *)paramDic {
    NSString *resJson;
    NSUInteger keyCount = [paramDic count];
    if(keyCount>0) {
        resJson = [Util makeJsonWithDic:paramDic];
    }
    NSString *callbackFunc = [NSString stringWithFormat:@"%@('%@');" ,funcNm, AvoidNil(resJson)];
    NSLog(@">>>>>> 자바스크립트 호출 : %@", callbackFunc);
    [[self curWebView] evaluateJavaScript:AvoidNil(callbackFunc) completionHandler:^(NSString *result, NSError *error) {
        NSLog(@">>>>>>> evaluateJavaScript 함수 : %@, result : %@, err : %@, ", callbackFunc, result ,error);
    }];
}


#pragma mark - WKNavigationDelegate

// 메모리 아웃 시 처리
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@">>>>>>> WKWebView webViewWebContentProcessDidTerminate");
    [webView reload];
}

// 웹뷰 로드 시작
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@">>>>>>> WKWebView didStartProvisionalNavigation");
    self.curUrlStr = [webView URL].absoluteString;
}

// 웹뷰 로드 종료
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@">>>>>>> WKWebView didFinishNavigation");
}

// 웹뷰 실패 처리
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@">>>>>>> WKWebView didFailProvisionalNavigation");
    // 통신 에러 시 네이티브에서 처리할 부분이 있다면.
    if (error && (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut || error.code == NSURLErrorCannotConnectToHost)) {
        
    }
}

// 웹뷰 response 처리
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@">>>>>>> WKWebView decidePolicyForNavigationResponse");
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}




/*
 KSPay 제공
 신용카드 관련 간편결제 앱 스킴
"itms-appss://";                     // 앱 스토어 - 사용 불가
"ispmobile://";                      // ISP
"payco://";                          // PAYCO
"kakaotalk://";                      // KAKAO
"shinsegaeeasypayment://";           // SSG PAY
"lpayapp://";                        // LPAY
"kb-acp://";                         // 국민 앱카드
"hdcardappcardansimclick://";        // 현대 앱카드
"shinhan-sr-ansimclick://";          // 신한 페이판
"mpocket.online.ansimclick://";      // 삼성 앱카드
"lotteappcard://";                   // 롯데카드 라이프앱
"cloudpay://";                       // 하나 1Q 페이
"hanawalletmembers://";              // 하나멤버스
"nhallonepayansimclick://";          // 농협 올원페이
"citimobileapp://";                  // 씨티 스마트 간편결제
"wooripay://";                       // 우리 페이(앱서비스 종료예정)
"com.wooricard.wcard://";            // 우리 원카드(신규오픈)
"shinhan-sr-ansimclick-naverpay://"; // 신한 네이버페이
"shinhan-sr-ansimclick-payco://";    // 신한 페이코
*/

/*
 계좌이체 관련 간편결제 앱 스킴
"kftc-bankpay://";    // 금결원
"kb-bankpay://";      // 금결원 (리브 국민은행)
"nhb-bankpay://";     // 금결원 (NH 앱캐시)
"kn-bankpay://";      // 금결원 (경남은행)
"mg-bankpay://";      // 금결원 (새마을금고)
"lguthepay-xpay://";  // LG 유플러스
"SmartBank2WB://";    // LG 유플러스
*/

// 웹뷰 action 처리
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *originalURL = navigationAction.request.URL.absoluteString;
    NSLog(@">>>>>>> WKWebView decidePolicyForNavigationAction original url : %@", originalURL);
    
    if (originalURL.length == 0) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if (navigationAction.request.URL == nil) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 전화, 메일 처리
    if([navigationAction.request.URL.scheme isEqualToString:@"tel"]
       ||[navigationAction.request.URL.scheme isEqualToString:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 파일 처리
    if([navigationAction.request.URL.scheme isEqualToString:@"file"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    // ASIS 지원
    // kftc-bankpay 연동
    if([originalURL hasPrefix:@"kftc-bankpay://"]) {
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            // 설치되어있다면 callbackparam1에 담긴 값을 얻기위해 작업
            // callbackparam1은 나이스에서 제공하는 리턴 URL이므로
            // 아래와 같이 NSLog를 통해 해당 부분이 잘 리턴되는지 필히 체크해보시길 바랍니다.
            NSArray *urlParams = [originalURL componentsSeparatedByString:@"&"];
            
            for (NSString* nameValue in urlParams) {
                NSArray* nv = [nameValue componentsSeparatedByString:@"="];
                if([nv containsObject:@"callbackparam1"]) {
                    for(NSString *value in nv) {
                        if(![value isEqualToString:@"callbackparam1"]) {
                            // URL인코딩 되어 리턴됩니다.
                            // 해당 스테이지에서 디코딩 해주셔도 문제 없습니다.
                            // 다만 디코딩하시면 requestBankPayResult메소드에서 하는 디코딩 작업을 삭제해주세요.
                            // 해당 부분 변경하지 않으실 것이라면 그대로 해당 스트링에 담아두시면 됩니다.
                            self.bankPayUrlString = value;
                        }
                    }
                }
            }
            NSLog(@"bankPayUrlString: %@",self.bankPayUrlString);
            
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%@ [Opened url] %@ !!!", originalURL, success ? @"Success" : @"Fail");
            }];
        }
        //설치 되어 있지 않다면 안내 팝업
        else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"알림"
                                                                                       message:@"Bank Pay가 설치되어 있지 않아\nApp Store로 이동합니다."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSString* URLString = @"http://itunes.apple.com/us/app/id398456030?mt=8";
                NSURL* storeURL = [NSURL URLWithString:URLString];

                [[UIApplication sharedApplication] openURL:storeURL options:@{} completionHandler:^(BOOL success) {
                    if(success) {
                        NSLog(@"unisign-app:// [Opened url] Success !!!");
                    }
                    else {
                        NSLog(@"unisign-app:// [Opened url] Fail !!!");
                    }
                }];

                [myAlertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
//            return NO;
            
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // ispmobile 연동
    else if([originalURL hasPrefix:@"ispmobile://"]) {
        if([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%@ [Opened url] %@ !!!", originalURL, success ? @"Success" : @"Fail");
            }];
        }
        //설치 되어 있지 않다면 app store 연결
        else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"알림"
                                                                                       message:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSString* URLString = @"http://itunes.apple.com/kr/app/id369125087?mt=8";
                NSURL* storeURL = [NSURL URLWithString:URLString];
                [[UIApplication sharedApplication] openURL:storeURL options:@{} completionHandler:^(BOOL success) {
                    NSLog(@"%@ [Opened url] %@ !!!", storeURL, success ? @"Success" : @"Fail");
                }];

                [myAlertController dismissViewControllerAnimated:YES completion:nil];
             }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // unisign 연동
    else if([originalURL hasPrefix:@"unisign-app://"]) {
        [HybridAdapter callUnisignByUri:nil uri:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // TOBE 추가 - 그밖에 KSPay 연동 항목
    else if ([originalURL hasPrefix:@"payco://"]
             || [originalURL hasPrefix:@"kakaotalk://"]
             || [originalURL hasPrefix:@"shinsegaeeasypayment://"]
             || [originalURL hasPrefix:@"lpayapp://"]
             || [originalURL hasPrefix:@"kb-acp://"]
             || [originalURL hasPrefix:@"hdcardappcardansimclick://"]
             || [originalURL hasPrefix:@"shinhan-sr-ansimclick://"]
             || [originalURL hasPrefix:@"shinhan-sr-ansimclick-naverpay://"]
             || [originalURL hasPrefix:@"shinhan-sr-ansimclick-payco://"]
             || [originalURL hasPrefix:@"lotteappcard://"]
             || [originalURL hasPrefix:@"cloudpay://"]
             || [originalURL hasPrefix:@"hanawalletmembers://"]
             || [originalURL hasPrefix:@"nhallonepayansimclick://"]
             || [originalURL hasPrefix:@"citimobileapp://"]
             || [originalURL hasPrefix:@"wooripay://"]
             || [originalURL hasPrefix:@"mpocket.online.ansimclick://"]
             || [originalURL hasPrefix:@"lguthepay-xpay://"]
             || [originalURL hasPrefix:@"SmartBank2WB://"]
             || [originalURL hasPrefix:@"kb-bankpay://"]
             || [originalURL hasPrefix:@"nhb-bankpay://"]
             || [originalURL hasPrefix:@"mg-bankpay://"]
             || [originalURL hasPrefix:@"kn-bankpay://"]
             || [originalURL hasPrefix:@"com.wooricard.wcard://"]
             || [originalURL hasPrefix:@"itms-appss://"]) {
        
        if([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%@ [Opened url] %@ !!!", originalURL, success ? @"Success" : @"Fail");
            }];
        }
        else {
            [self noAppDialog];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    else if ([originalURL hasPrefix:@"kakaolink://"]){
        if([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%@ [Opened url] %@ !!!", originalURL, success ? @"Success" : @"Fail");
            }];
        }
        else {
            [self noAppDialog];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark - WKUIDelegate

// opener 종료 처리
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@">>>>>>>> WKWebView webViewDidClose");
    
    // createdWKWebViews base 웹뷰는 삭제할 수 없다.
    if([self.createdWKWebViews count]>1) {
        // 현재 WkWebview 삭제 및 Delegate와 Setting 처리
        [self removeWebViewAfterAnimate:webView];
    }
}

// opener 오픈 처리
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    NSString *absoluteString = navigationAction.request.URL.absoluteString;
    NSLog(@">>>>>>>> WKWebView createWebViewWithConfiguration url: %@", absoluteString);
    
    // ASIS
//    WKWebView *newWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
//    [self addChildWebView:newWebView];
//    return newWebView;

    // 필터링
    if([self isExternalUrl:absoluteString]) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:absoluteString]]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%@ [Opened url] %@ !!!", absoluteString, success ? @"Success" : @"Fail");
            }];
        }
        return nil;
    }
    else {
        // child webview 추가
        WKWebView *newWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        [self addChildWebView:newWebView];
        return newWebView;
    }
}

- (BOOL)isExternalUrl:(NSString *) url {
    if([url containsString:@"hansalim.or.kr"]){
        return NO;
    }
    else if([url containsString:@"192.168.0.30"]){
        return NO;
    }
    else {
        return YES;
    }
}


// 웹뷰 alert 처리
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@">>>>> runJavaScriptAlertPanelWithMessage : %@", message);
    dispatch_async(dispatch_get_main_queue(), ^(){
        if(message.length==0) {
            completionHandler();
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert]; [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { completionHandler(); }]]; [self presentViewController:alertController animated:YES completion:^{}];
        }
    });
}

// 웹뷰 confirm 처리
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@">>>>> runJavaScriptConfirmPanelWithMessage : %@", message);
    dispatch_async(dispatch_get_main_queue(), ^(){

        if(message.length==0) {
            completionHandler(NO);
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    completionHandler(YES);
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    completionHandler(NO);
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}





#pragma mark - Barcode Delegate
-(void) resultBarcode:(NSString *) data {
//    NSString *msg = [NSString stringWithFormat:@"Hybrid.resultBarcode(\"%@\");", data];
//    NSLog(@"Barcode Delegate [%@]", msg);
//    [_mWebView stringByEvaluatingJavaScriptFromString:msg];
    
    [self callJavaScript:self.tempCallbackFunc paramDic:@{
                                    @"data":AvoidNil(data)
    }];
}



#pragma mark - SignInDelegate
-(void)sendWebReturn : (NSString*)sidCheck sidResult:(NSString*)sidResult britgeName:(NSString*)britgeName {
    NSString *callbackFunc = [NSString stringWithFormat:@"%@('%@','%@')" ,britgeName, AvoidNil(sidCheck), AvoidNil(sidResult)];
    NSLog(@"SignInDelegate >>> sendWebReturn >>> 자바스크립트 호출 : %@", callbackFunc);
    [[self curWebView] evaluateJavaScript:AvoidNil(callbackFunc) completionHandler:^(NSString *result, NSError *error) {
        NSLog(@">>>>>>> evaluateJavaScript 함수 : %@, result : %@, err : %@, ", callbackFunc, result ,error);
    }];
}

- (void)moveToLink : (NSString*)Link {
     NSLog(@"moveToLink : %@", Link);
    [self move:Link];
}

- (void)showAlarm:(NSString *)text moveUrl:(NSString*) url {
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"알림"
                                                                               message:text
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"확인"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             NSArray *linkMesserds = [url componentsSeparatedByString:@"http"];
                             if(linkMesserds.count > 1) {
                                 if(url != nil) {
                                     [self moveToLink:url];
                                 }
                             }
                             else {
                                 if(url != nil) {
                                     [self moveToLink:[NSString stringWithFormat:@"%@/#%@",BASE_URL, url]];
                                 }
                             }
                         }];
    [myAlertController addAction: ok];
    [self presentViewController:myAlertController animated:YES completion:nil];
}

- (void)move:(NSString*)urlAddress {
    NSLog(@"move in :::::::::");
    NSURL *appURL = [NSURL URLWithString:urlAddress];
    
    if(![appURL scheme]) {
        NSString *startFilePath = [[self class] pathForResource:urlAddress];
        if (startFilePath == nil) {
            appURL = [NSURL URLWithString:[urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            appURL = [NSURL fileURLWithPath:startFilePath];
        }
    }
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:appURL];
    [[self curWebView] loadRequest:requestObj];
}

- (void) noAppDialog {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"알림"
                                                                             message:@"해당 앱이 설치 되어 있지 않습니다."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark - WKHTTPCookieStoreObserver
- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore {
    NSLog(@"cookiesDidChangeInCookieStore [%@]", cookieStore);
}

@end

