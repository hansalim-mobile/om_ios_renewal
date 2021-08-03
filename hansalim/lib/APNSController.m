//
//  APNSController.m
//  Catch Job
//
//  Created by Sewon Na on 11. 12. 30..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//
#import "APNSController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation APNSController

+(APNSController *)singleton {
	static dispatch_once_t pred;
	static APNSController *shared = nil;
	
	dispatch_once(&pred, ^{
		shared = [[APNSController alloc] init];
	});
	return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }    
    return self;
}

- (void)registerThisDeviceWithDeviceToken:(NSData *)devToken  {
    

#if !TARGET_IPHONE_SIMULATOR
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSString *appName = ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] == nil)?@"":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appBuildNumber = ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ==nil)?@"":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appVersion = ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]==nil)?@"":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
    
    NSString *pushBadge;
    NSString *pushAlert;
    NSString *pushSound;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        
        UIUserNotificationType types = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        
        if (types == UIUserNotificationTypeNone) {
            pushBadge = (types & UIUserNotificationTypeBadge) ? @"enabled" : @"disabled";
            pushAlert = (types & UIUserNotificationTypeAlert) ? @"enabled" : @"disabled";
            pushSound = (types & UIUserNotificationTypeSound) ? @"enabled" : @"disabled";
        }
        
    } else {
        
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        	// Set the defaults to disabled unless we find otherwise...
        if (types == UIRemoteNotificationTypeNone) {
           pushBadge = (types & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
           pushAlert = (types & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
           pushSound = (types & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
        }
    }
	



	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
    
	NSString *deviceName = [dev.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSString *deviceModel = [dev.model stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSString *deviceSystemVersion = dev.systemVersion;

	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description] 
							   stringByReplacingOccurrencesOfString:@"<"withString:@""] 
							  stringByReplacingOccurrencesOfString:@">" withString:@""] 
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
    NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:appName,@"appname",
                            appVersion,@"appversion",
                            appBuildNumber,@"appBuildNumber",
                            deviceName,@"deviceName",
                            deviceModel,@"deviceModel",
                            deviceSystemVersion,@"deviceSystemVersion",
                            deviceToken,@"deviceToken",
                            pushBadge,@"pushBadge",
                            pushAlert,@"pushAlert",
                            pushSound,@"pushSound", nil];
    


	[[NSUserDefaults standardUserDefaults] setObject:device forKey:@"deviceInfo"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    

#endif
}

- (void) receiveMessage:(UIApplication *)application message:(NSDictionary *)message {

#if !TARGET_IPHONE_SIMULATOR
    /*
	NSLog(@"remote notification: %@",[message description]);
	NSDictionary *apsInfo = [message objectForKey:@"aps"];
	
	NSDictionary *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	
    // 앱뱃지 설정
    //application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
	
    // 직접 호출
    //AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate.tabBarController receivePush:action];
    
	// notifacation center를 이용한 방법
	[[NSNotificationCenter defaultCenter] postNotificationName:@"push_received" object:self];
    
    NSString *msg = [alert objectForKey:@"loc-key"];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" 
														message:msg 
													   delegate:self 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
    [alertView show];*/
#endif
}


@end
