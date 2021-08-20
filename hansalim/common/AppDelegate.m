//
//  AppDelegate.m
//  hansalim
//
//  Created by marco on 2021/06/10.
//

#import "AppDelegate.h"
#import "PushHepler.h"
#import "HybridAdapter.h"

@import UserNotifications;

@interface AppDelegate () <UNUserNotificationCenterDelegate> {
    NSString *sidCheck;
    NSString *sidResult;
    NSString *usigignBridgeName;
    NSString *pushLink;
    NSString *ispSuccesLink;
}

@end

@implementation AppDelegate
@synthesize delegate;

NSString *const kGCMMessageIDKey = @"gcm.message_id";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]

    // [START set_messaging_delegate]
    [FIRMessaging messaging].delegate = self;
    // [END set_messaging_delegate]

    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    // [START register_for_notifications]

      
      // iOS 10 or later
      // For iOS 10 display notification (sent via APNS)
      [UNUserNotificationCenter currentNotificationCenter].delegate = self;

      UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;

      [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // ...
      }];


    [application registerForRemoteNotifications];
    // [END register_for_notifications]
    
    
    
    return YES;
}






- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired till the user taps on the notification launching the application.
  // TODO: Handle data of notification

  // With swizzling disabled you must let Messaging know about the message, for Analytics
   [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  // [START_EXCLUDE]
  // Print message ID.
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  // [END_EXCLUDE]

  // Print full message.
  NSLog(@"%@", userInfo);
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired till the user taps on the notification launching the application.
  // TODO: Handle data of notification

  // With swizzling disabled you must let Messaging know about the message, for Analytics
   [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  // [START_EXCLUDE]
  // Print message ID.
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  // [END_EXCLUDE]

  // Print full message.
  NSLog(@">>> didReceiveRemoteNotification Print full message <<<");
  NSLog(@"%@", userInfo);

  completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  NSDictionary *userInfo = notification.request.content.userInfo;

  // With swizzling disabled you must let Messaging know about the message, for Analytics
   [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  // [START_EXCLUDE]
  // Print message ID.
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }
  // [END_EXCLUDE]

  // Print full message.
  NSLog(@">>> userNotificationCenter willPresentNotification Print full message <<<");
  NSLog(@"%@", userInfo);

  // Change this to your preferred presentation option
  completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  if (userInfo[kGCMMessageIDKey]) {
    NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
  }

  // With swizzling disabled you must let Messaging know about the message, for Analytics
   [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  // Print full message.
  NSLog(@">>> userNotificationCenter didReceiveNotificationResponse Print full message <<<");
  NSLog(@"%@", userInfo);
    
  [[PushHepler getInstance] setPushUrlFromApnsPayload:userInfo];
  [[NSNotificationCenter defaultCenter] postNotificationName:kApnsNoti object:self];

  completionHandler();
}

// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:fcmToken forKey:@"_token"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"APNs device token retrieved: %@", deviceToken);

  // With swizzling disabled you must set the APNs device token here.
  // [FIRMessaging messaging].APNSToken = deviceToken;
}





#pragma mark - ASIS Hansalim Code

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSDictionary *dict = [self parseQueryString:[url query]];
    NSLog(@"application openURL sourceApplication annotation \n NSDictionary Data \n%@", dict );
    NSLog(@"callback Data \n%@",[dict objectForKey:@"callback"]);
    
    //공인인증서 인증 ok
    if([[dict objectForKey:@"sidCheck"]isEqualToString:@"0"]) {
        sidCheck = @"true";
        sidResult = [dict objectForKey:@"result"];
        usigignBridgeName = [dict objectForKey:@"callback"];
        return YES;
    }
    else if([[dict objectForKey:@"sidCheck"]isEqualToString:@"1"]) {
        sidCheck = @"false";
        sidResult = @"false";
        usigignBridgeName = [dict objectForKey:@"callback"];
        return YES;
    }
    
    //isp인증 결제 OK 콜백
    NSString * ispUrlString = [url absoluteString];
    NSRange range = [ispUrlString rangeOfString:@"ispResultTr.jsp"];
    if(range.location != NSNotFound) { //ISP 인증 후 결제 진행
        NSArray *components = [ispUrlString componentsSeparatedByString:@"hansalimapp://card://"];
        if ([components count] > 1) {
            ispSuccesLink = [components objectAtIndex:1];
            return YES;
        }
    }
    
    return NO;
}

// TOBE
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSDictionary *dict = [self parseQueryString:[url query]];
    NSLog(@"application openURL options \n NSDictionary Data \n%@", dict );
    NSLog(@"callback Data \n%@",[dict objectForKey:@"callback"]);

    //공인인증서 인증 ok
    if([[dict objectForKey:@"sidCheck"]isEqualToString:@"0"]) {
        sidCheck = @"true";
        sidResult = [dict objectForKey:@"result"];
        usigignBridgeName = [dict objectForKey:@"callback"];
        return YES;
    }
    else if([[dict objectForKey:@"sidCheck"]isEqualToString:@"1"]) {
        sidCheck = @"false";
        sidResult = @"false";
        usigignBridgeName = [dict objectForKey:@"callback"];
        return YES;
    }
    
    //isp인증 결제 OK 콜백
    NSString * ispUrlString = [url absoluteString];
    NSRange range = [ispUrlString rangeOfString:@"ispResultTr.jsp"];
    if(range.location != NSNotFound) { //ISP 인증 후 결제 진행
        NSArray *components = [ispUrlString componentsSeparatedByString:@"hansalimapp://card://"];
        if ([components count] > 1) {
            ispSuccesLink = [components objectAtIndex:1];
            return YES;
        }
    }
    
    return NO;
    
} // return NO if the application can't open for some reason



- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val;
        if(elements.count == 2) {
            val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else if(elements.count > 2) {
            NSString * replaceString;
            for(int i = 1;i<elements.count;i++) {
                NSString * makeString = [[elements objectAtIndex:i] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                replaceString = [NSString stringWithFormat:@"%@%@",(replaceString != nil)?replaceString:@"",(makeString.length < 1)?@"=":makeString];
            }
            val = [replaceString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        }
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    [[NSNotificationCenter defaultCenter] postNotificationName:kWillResignActive object:self];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"Cookies"];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cookies"];
    if ([cookiesData length])
    {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for ( NSHTTPCookie *cookie in cookies )
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    if(sidCheck != nil && sidResult != nil) {
        [delegate sendWebReturn:sidCheck sidResult:sidResult britgeName:usigignBridgeName];
        sidCheck = nil;
        sidResult = nil;
        usigignBridgeName = nil;
    }
//    else if(pushLink != nil) {
//        [delegate moveToLink:pushLink];
//        NSLog(@"push link : %@", pushLink);
//    }
    else if(ispSuccesLink != nil) {
        [delegate moveToLink:ispSuccesLink];
        ispSuccesLink = nil;
    }
    
    application.applicationIconBadgeNumber = 0;
}


@end
