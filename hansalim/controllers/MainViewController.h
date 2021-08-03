//
//  MainViewController.h
//  hansalim
//
//  Created by marco on 2021/06/16.
//

#import <WebKit/WebKit.h>
#import "Util.h"
#import "UIView+CustomConstraint.h"
#import "PushHepler.h"
#import "BarcodeViewController.h"
#import "JSONRequestDictionary.h"

@interface MainViewController : UIViewController <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate, UIScrollViewDelegate, BarcodeResultDelegate, WKHTTPCookieStoreObserver>

@property (nonatomic, retain) NSMutableArray *createdWKWebViews; // 생성된 웹뷰들
@property (nonatomic, retain) NSString *curUrlStr;
@property (weak, nonatomic) IBOutlet UIView *wkContainer;
@property(nonatomic,retain)  NSString* bankPayUrlString;

//===================== 브릿지 관련 값 Begin =====================
@property (nonatomic, retain) NSString *tempCallbackFunc; // 임시 콜백 함수명
@property (nonatomic, retain) NSString *tempJsonTxt; // 임시 json 값 저장


@end
