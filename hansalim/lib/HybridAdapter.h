//
//  HybridAdapter.h
//  H2AAdapter
//
//  Created by gychoi on 12. 5. 26..
//  Copyright 2012 Crosscert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface HybridAdapter : NSObject {

}

+ (BOOL) isUniSignInstalled;
+ (BOOL) callUnisignByUri:(UIWebView *)webView uri:(NSURLRequest *)uri;
+ (BOOL) callWebResultByScheme:(NSURL *)uri;
+ (void) setWKWebView:(WKWebView *)wkWebView;

@end
