//
//  JSONRequestDictionary.m
//  ButtonUP
//
//  Created by SeWon.Na on 12. 10. 18..
//  Copyright (c) 2012년 REDWORKS. All rights reserved.
//

#import "JSONRequestDictionary.h"
#import <UIKit/UIKit.h>

@interface JSONRequestDictionary () <NSURLConnectionDelegate> {
	SEL completion;
	SEL failed;
}
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSTimer *connectionTimer;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) id target;
- (NSMutableURLRequest*) buildRequest:(NSString *)url query:(NSDictionary*)jsonQuery;
- (NSMutableURLRequest*) buildMultipartRequest:(NSString *)url query:(NSDictionary*)jsonQuery;
@end


@implementation JSONRequestDictionary
@synthesize dictionary, array, connectionTimer, connection, receivedData, response, target;

#pragma mark -
#pragma mark NSDictionary Overrides

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self != nil)
    {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        array = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

- (id)copy
{
	return [self mutableCopy];
}
- (void)setObject:(id)anObject forKey:(id)aKey
{
    if (![dictionary objectForKey:aKey])
    {
        [array addObject:aKey];
    }
    [dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
    [dictionary removeObjectForKey:aKey];
    [array removeObject:aKey];
}

- (NSUInteger)count
{
    return [dictionary count];
}

- (id)objectForKey:(id)aKey
{
    return [dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [array objectEnumerator];
}

#pragma mark -
#pragma mark Internal method

- (NSMutableURLRequest*) buildRequest:(NSString *)url query:(NSDictionary*)jsonQuery
{
    // setting up the request object now
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:5.0f];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
	NSMutableArray *parts = [[NSMutableArray array] init];
	NSString *part;
	
	for (id key in jsonQuery) {
        
		id value = [jsonQuery objectForKey:key];
		
		if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] ||
            [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSMutableArray class]] ) {
			// NSDictionary 와 NSArray 는 통채로 스트링으로 변환해서 보낸다
			// 받는 쪽에서 json_decode 해서 쓰면됨
			NSError* error = nil;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
			NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
			part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], jsonString];
		}
		else {
			part = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                    [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		[parts addObject:part];
	}
    
	// 값들을 &로 연결하여 Body에 사용
	[request setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
  //  NSLog(@" %@", [parts componentsJoinedByString:@"&"]);
    return request;
}


- (NSMutableURLRequest*) buildMultipartRequest:(NSString *)url query:(NSDictionary*)jsonQuery {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:5.0f];
    
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
    
	NSString *boundary = @"------safdadfjgmctyre99882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	NSMutableData *ImgBody = [NSMutableData data];
	
	for (id key in jsonQuery) {
        
		id value = [jsonQuery objectForKey:key];
		
		// Key값이 image인 경우 imageBody에 붙이며 나중에 HTTPBody 맨뒤에 붙는다.
		//if ([key isEqualToString:@"image"]) {
		if ( [value isKindOfClass:[UIImage class]] ) {
			NSData *imageData= UIImageJPEGRepresentation(value, 90);//[NSData dataWithData:UIImagePNGRepresentation(value)];
			
			[ImgBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[ImgBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", @"TEMP.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
			[ImgBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[ImgBody appendData:imageData];
			[ImgBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		else if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] ||
                 [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSMutableArray class]] ) {
			// NSDictionary 와 NSArray 는 통채로 스트링으로 변환해서 보낸다
			// 받는 쪽에서 json_decode 해서 쓰면됨
			NSError* error = nil;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error];
			NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
			[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		else {
            // HTTP Body를 설정한다. POST값으로 보낼 값들을 설정한다.
			[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, value] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	// ImageBody는 요청헤더 Body의 맨 뒤에 붙인다.
	[body appendData:ImgBody];
    
	// Body의 맨끝에 마지막 데이타라는 것을 명시하기 위한 Boundary를 입력한다. (HTTP규약 참고)
	[body appendData:[[NSString stringWithFormat:@"--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
    
    return request;
}

#pragma mark -
#pragma mark Public methods

- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) completionBlock
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail
{
    [self sendAsynchronousRequest:url completion:completionBlock success:success fail:fail multipart:NO];
}

- (void) sendAsynchronousRequest :(NSString *)url
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail
{
    [self sendAsynchronousRequest:url success:success fail:fail multipart:NO];
}
- (void) sendAsynchronousRequest :(NSString *)url
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail
                        multipart:(BOOL)multipart
{
    [self sendAsynchronousRequest:url completion:nil success:success fail:fail multipart:YES];
}

- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) block
{
    [self sendAsynchronousRequest:url completion:block multipart:NO];
}

- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) block
                        multipart:(BOOL)multipart
{
    [self sendAsynchronousRequest:url completion:block success:nil fail:nil multipart:YES];
}


- (void) sendAsynchronousRequest :(NSString *)url
                       completion:(void (^)(NSDictionary * response, NSError * error)) completionBlock
                          success:(void (^)(NSDictionary * response)) success
                             fail:(void (^)(NSError * error)) fail
                        multipart:(BOOL)multipart {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
#ifdef DEBUG
       // NSLog(@"<<<<<<<<<<<<<<<<<<<<<<");
        //NSLog(@"query(%@): %@", url, self);
        //NSLog(@"<<<<<<<<<<<<<<<<<<<<<<\n");
#endif
        NSError * error = nil;
        NSDictionary *jsonResponse = [self sendSynchronousRequest:url error:error multipart:multipart];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(jsonResponse, error);
        });
        
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(jsonResponse);
            });
        }
        else {
            fail(error);
        }
    });
}

- (NSDictionary*) sendSynchronousRequest :(NSString *)url
                                    error:(NSError *)error
                                multipart:(BOOL)multipart;
{
    NSMutableURLRequest *request = (multipart)? [self buildMultipartRequest:url query:self]:[self buildRequest:url query:self];
	NSURLResponse *response_ =nil;
	NSData* jsonData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response_
                                                         error:&error];
    if (error != nil) {
#ifdef DEBUG
      //  NSLog(@"err: %@", error );
#endif
        return nil;
    }
    
	// 받은 데이터(JSON)를 NSDictionary로 변환
    NSDictionary *json = nil;
	@try {
        json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
#ifdef DEBUG
    //    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
     //   NSLog(@"response: %@", json);
      //  NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
#endif
    }
    @catch (NSException *exception) {
        // 확인용
#ifdef DEBUG
     //   NSLog(@">>>>>>>> JSONRequestDictionary:NSException <<<<<<<<<<<");
      //  NSLog(@"exception:%@ \n %@", exception, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
#endif
        return nil;
    }
    
	return json;
}
@end

@implementation NSURLRequest (IgnorePrivateSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
 
