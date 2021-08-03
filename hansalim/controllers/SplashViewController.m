//
//  SplashViewController.m
//  hansalim
//
//  Created by marco on 2021/06/16.
//

#import "SplashViewController.h"

@interface SplashViewController() {
    BOOL isLoadImage;       // 이미지 로딩, 혹은 대체 이미지 적용 완료 여부
    BOOL isChkVersion;         // 버전 체크 완료 여부
    int splashTime;
}

@end

@implementation SplashViewController

@synthesize splashImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    splashTime = 1;
    if([Util connectedToNetwork]) {
        [self setSplashImage];
        
        // 최초 토큰이 없는 상태로 진입해야 할경우
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"_token"] == nil) {
            [self nonDeviceCheck];
        }
        else {
            [self deviceCheck];
        }
    }
}


// 스플래시 이미지 가져와서 설정
- (void) setSplashImage {
    JSONRequestDictionary *query = [[JSONRequestDictionary alloc] init];
    [query sendAsynchronousRequest:LOADING_GIF
                        completion:^(NSDictionary *response, NSError *error) {
                        } success:^(NSDictionary *response) {
                            NSLog(@"loding gif %@",response);
                            NSLog(@"loding gif imageurl %@",[response objectForKey:@"imageUrl"]);
                            if([response objectForKey:@"imageUrl"] != nil) {
                                NSNumber* duration = [response valueForKey:@"duration"];
                                self -> splashTime = [duration intValue];
                                self -> splashImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:[response objectForKey:@"imageUrl"]]];
                            }
                            else {
                                NSString *filePath = [[NSBundle mainBundle] pathForResource: @"introS" ofType: @"gif"];
                                NSData *gifData = [NSData dataWithContentsOfFile: filePath];
                                self -> splashImageView.image = [UIImage animatedImageWithAnimatedGIFData:gifData];
                            }
                            self -> isLoadImage = true;
                            [self goToMain];
                            NSLog(@"Splash LoadImage Complete !!");
                        } fail:^(NSError *error) {
                            [self setSplashImage];
                        }];
}


-(void) nonDeviceCheck {
    NSLog(@"nonDeviceCheck start");
    JSONRequestDictionary *query = [[JSONRequestDictionary alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@?nonDevice=Y&deviceType=IOS",DEVICE_CHECK];
    
    [query sendAsynchronousRequest:url
                        completion:^(NSDictionary *response, NSError *error) {
                        } success:^(NSDictionary *response) {
                            NSLog(@"nonDeviceCheck$ %@",response);
                            if([[response objectForKey:@"result"]isEqualToString:@"success"]) {
                                //임시 디바이스토큰 저장
                                NSString * nonDeviceToken = [[response objectForKey:@"deviceInfo"]objectForKey:@"deviceRegId"];
                                if([[NSUserDefaults standardUserDefaults] objectForKey:@"_token"] == nil) {
                                    NSLog(@"nonDeviceCheck return and userDefaults token is null !!");
                                    [[NSUserDefaults standardUserDefaults] setObject:nonDeviceToken forKey:@"_token"];
                                }
                                //앱 버젼 체크
                                [self appVersionCheck :[response objectForKey:@"lastAppVer"] forcUpdate:[response objectForKey:@"forcUploadYn"]];
                            }
                            else {
                                [self nonDeviceCheck];
                            }
                            
                        } fail:^(NSError *error) {
                            
                        }];
}



-(void) deviceCheck {
    NSLog(@"DeviceCheck start");
    JSONRequestDictionary *query = [[JSONRequestDictionary alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@?deviceRegId=%@&deviceType=IOS",DEVICE_CHECK,[[NSUserDefaults standardUserDefaults] objectForKey:@"_token"]];
    NSLog(@"DeviceCheck url %@",url);
    [query sendAsynchronousRequest:url
                        completion:^(NSDictionary *response, NSError *error) {
                            
                        } success:^(NSDictionary *response) {
                            NSLog(@"deviceCheck$ %@",response);
                            if([[response objectForKey:@"result"]isEqualToString:@"success"]) {
                                //앱 버젼 체크
                                [self appVersionCheck :[response objectForKey:@"lastAppVer"] forcUpdate:[response objectForKey:@"forcUploadYn"]];
                            }
                            else {
                                [self deviceCheck];
                            }
                            
                        } fail:^(NSError *error) {
                            
                        }];
}


-(void) appVersionCheck :(NSString*)nowVersion forcUpdate :(NSString*)forcUpdate {
    
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString* push = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushId"];
    if(push != nil) {
        [self checkPushRead];
    }
    
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    nowVersion = [nowVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    double aV = [appVersion doubleValue];
    double nV = [nowVersion doubleValue];
    
    NSLog(@"appVersionCheck AppVersion is [%f] and Server version is [%f]", aV , nV);
    
    if(nV > aV) {
        if([forcUpdate isEqualToString:selectY]) {
            [self goAPPStore];
        }
        else {
            [self selectGoAPPStore];
        }
    }
    else {
        isChkVersion = true;
        [self goToMain];
    }
    
}

// 강제 업데이트 필요한 경우
-(void) goAPPStore {
    if(![Util connectedToNetwork]) return;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"alert_title".localized
                                                                             message:@"force_update_msg".localized
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSString *iTunesLink = ITUNESLINK;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:^(BOOL bSuccess) {
            if( bSuccess ) {
                NSLog(@"goAPPStore Success !!");
            }
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

// 선택적 업데이트 안내
-(void) selectGoAPPStore {
    if(![Util connectedToNetwork]) return;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"alert_title".localized
                                                                             message:@"select_update_msg".localized
                                                                      preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *iTunesLink = ITUNESLINK;
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:^(BOOL bSuccess) {
                if( bSuccess ) {
                    NSLog(@"goAPPStore Success !!");
                }
            }];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            self -> isChkVersion = true;
            [self goToMain];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
}

// 푸시 메세지 읽음 처리
- (void)checkPushRead {
    JSONRequestDictionary *query = [[JSONRequestDictionary alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@%@&deviceRegId=%@",PUSH_READ,[[NSUserDefaults standardUserDefaults] objectForKey:@"pushId"],[[NSUserDefaults standardUserDefaults] objectForKey:@"_token"]];
    [query sendAsynchronousRequest:url
                        completion:^(NSDictionary *response, NSError *error) {
                        } success:^(NSDictionary *response) {
                            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pushId"];
                        } fail:^(NSError *error) {
                        }];
}

-(void)goToMain {
    NSLog(@">>>>>>> goToMain  Check Result isLoadImage [%d], isChkVersion [%d] <<<<<<<" , isLoadImage, isChkVersion);
    if(isLoadImage && isChkVersion) {
        UINavigationController *baseNaviC = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"naviController"];
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topController.presentedViewController) {
                topController = topController.presentedViewController;
            }
        baseNaviC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        baseNaviC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        if(!splashTime){
            // 값이 없는 경우 default value
            splashTime = 2;
        }
        else if(splashTime > 10){
            // 비정상적으로 큰 경우 default value
            splashTime = 2;
        }
        // TODO 시간 설정 필요
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(splashTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [topController presentViewController:baseNaviC animated:YES completion:nil];
        });
    }
}



@end
