//
//  JSONRequestDictionary.h
//  ButtonUP
//
//  Created by SeWon.Na on 12. 10. 18..
//  Copyright (c) 2012년 REDWORKS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONRequestDictionary : NSMutableDictionary
/*!
 @method      sendAsynchronousRequest:self url:url:completion:multipart:
 @abstract
 @discussion
 @param
 @result
 */
- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) block;

- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) block
                        multipart:(BOOL)multipart;

- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) completionBlock
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail;

- (void) sendAsynchronousRequest :(NSString *)url
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail;

- (void) sendAsynchronousRequest :(NSString *)url
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail
                        multipart:(BOOL)multipart;

- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) completionBlock
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail
                        multipart:(BOOL)multipart;

/*!
 @method      sendSynchronousRequest:url:completion:multipart:
 @abstract
 @discussion
 @param
 @result
 */
- (NSDictionary*) sendSynchronousRequest :(NSString *)url
                                    error:(NSError *)error
                                multipart:(BOOL)multipart;
@end
