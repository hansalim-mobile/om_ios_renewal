//
//  APNSController.h
//  Catch Job
//
//  Created by Sewon Na on 11. 12. 30..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define APNS	[APNSController singleton] 

@interface APNSController : NSObject

+(APNSController*)singleton;
- (void) sendMessage :(NSString*)role name:(NSString*)name from:(NSString*)from to:(NSString*)to msg:(NSString*)msg;
- (void) sendMessage :(NSString*)msg type:(NSString*)type sender:(NSString*)sID;
- (void) registerThisDeviceWithDeviceToken:(NSData *)devToken ;
- (void) receiveMessage:(UIApplication *)application message:(NSDictionary *)message;

@end
