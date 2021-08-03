//
//  AppDelegate.h
//  hansalim
//
//  Created by marco on 2021/06/10.
//

#import <UIKit/UIKit.h>
@import Firebase;

@protocol SignInDelegate<NSObject>
@required
- (void)sendWebReturn : (NSString*)sidCheck sidResult:(NSString*)sidResult britgeName:(NSString*)britgeName;
- (void)moveToLink : (NSString*)Link;
- (void)showAlarm:(NSString *)text moveUrl:(NSString*) url;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, FIRMessagingDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) id<SignInDelegate> delegate;

@end

