//
//  Util.m
//  hansalim
//
//  Created by NT0154 on 2017. 12. 12..
//  Copyright © 2017년 NT0154. All rights reserved.
//

#import "Reachability.h"
#import "Util.h"

@implementation Util

#pragma mark - Check Network

+ (BOOL)connectedToNetwork
{
    /*
     인터넷 연결 상태를 확인합니다.
     ReachableViaWiFi && ReachableViaWWAN
     : Wi-fi와 3G 둘다 안된다면 인터넷이 연결되지 않은 상태입니다.
     */
    
    Reachability *r = [Reachability reachabilityWithHostname:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL internet;
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
        internet = NO;
    } else {
        internet = YES;
    }
    return internet;
    
    
    /*  Reachability *reachability = [Reachability reachabilityForInternetConnection];
     NetworkStatus networkStatus = [reachability currentReachabilityStatus];
     return networkStatus != NotReachable;*/
    
}

+ (void)canNotNetwork {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" message:@"네트워크에 연결할 수 없습니다."  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Check PUSH
+ (BOOL)pushNotificationsEnabled
{
    
    BOOL isgranted = false;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
        {
            isgranted =  [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
            NSLog(@"test push y/n %@",(isgranted == YES)? @"YES":@"NO");
        }else{
            
        }
    }else{
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert)
        {
            
            isgranted = true;
        }else{
            
        }
    }
    return isgranted;
    
}

+ (NSString*) pathForResource:(NSString*)resourcepath
{
    NSArray *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [dir objectAtIndex:0];
    return [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", resourcepath]];
}

+ (BOOL) downloadFile:(NSString*)uri
{
    
    NSString *urlString = uri;
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *receivedData = [NSData dataWithContentsOfURL:url];
    
    NSString *documentPath = [Util pathForResource:uri];
    
    // 디렉토리 확인
    NSString* onlyPath = [documentPath stringByDeletingLastPathComponent] ;
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:onlyPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    
    return [receivedData writeToFile:documentPath atomically:YES];
}








// WK 캐쉬 삭제
+ (void)removeWkWebCache {
    // Optional data
//    NSSet *websiteDataTypes = [NSSet setWithArray:@[
//                                                    WKWebsiteDataTypeDiskCache,
//                                                    //WKWebsiteDataTypeOfflineWebApplicationCache,
//                                                    WKWebsiteDataTypeMemoryCache,
//                                                    //WKWebsiteDataTypeLocalStorage,
//                                                    //WKWebsiteDataTypeCookies,
//                                                    //WKWebsiteDataTypeSessionStorage,
//                                                    //WKWebsiteDataTypeIndexedDBDatabases,
//                                                    //WKWebsiteDataTypeWebSQLDatabases,
//                                                    //WKWebsiteDataTypeFetchCache, //(iOS 11.3, *)
//                                                    //WKWebsiteDataTypeServiceWorkerRegistrations, //(iOS 11.3, *)
//                                                    ]];
    // All kinds of data
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    // Date from
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    // Execute
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
}

+ (NSDateFormatter *)getDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"]];
    [formatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    return formatter;
}

// 날짜 포멧팅 변경
+(NSString *)changeDateFormat:(NSString *)dateStr oriFormatStr:(NSString *)oriFormatStr targetFormatStr:(NSString *)targetFormatStr {
    NSDateFormatter *dateFormatter = [self getDateFormatter];
    dateFormatter.dateFormat = oriFormatStr;
    NSDate *targetDate = [dateFormatter dateFromString:dateStr];
    dateFormatter.dateFormat = targetFormatStr;
    NSString *result = [dateFormatter stringFromDate:targetDate];
    return result;
}

// udid 가져오기
+ (NSString *)getDeviceUDID {
    NSString *deviceUdid;
    AqKeychainItemWrapper *wrapper = [[AqKeychainItemWrapper alloc] initWithIdentifier:kAqUdid accessGroup:nil];
    NSString *curUdid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    // 저장된 udid 가져오기
    if(curUdid.length>0) {
        deviceUdid = curUdid;
    }
    // 저장된 udid가 없는 경우 새로 만들기
    else {
        deviceUdid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        // 새로운 udid 저장
        [wrapper setObject:deviceUdid forKey:(__bridge id)(kSecAttrAccount)];
    }
    return deviceUdid;
}

// uuid 가져오기
+ (NSString *)getDeviceUUID {
    NSString *deviceUuid;
    NSString *curDeviceId = [[NSUserDefaults standardUserDefaults] valueForKey:kAqUuid];
    // 저장된 uuid 가져오기
    if(curDeviceId.length>0) {
        deviceUuid = curDeviceId;
    }
    // 저장된 uuid가 없는 경우 새로 만들기
    else {
        deviceUuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        // 새로운 uuid 저장
        [[NSUserDefaults standardUserDefaults] setObject:deviceUuid forKey:kAqUuid];
    }
    return deviceUuid;
}

// 마이너스 일전 날짜 취득
+(NSDate *)getMinusDayAgoDate:(NSInteger)minusDay
{
    //today
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    //today-2
    NSDateComponents *com = [[NSDateComponents alloc] init];
    [com setYear:[components year]];
    [com setMonth:[components month]];
    [com setDay:[components day]-minusDay];
    [com setHour:00];
    [com setMinute:00];
    [com setSecond:00];
    
    return [[NSCalendar currentCalendar] dateFromComponents:com];
}

// 이미지의 사이즈를 조절
+(UIImage *)resizeImage:(UIImage *)targetImg maxSize:(CGSize)maxSize
{
    // 만약 이미지가 nil이 거나 size가 0인 경우 원본을 넘긴다.
    if(!targetImg||targetImg.size.width==0||targetImg.size.height==0){
      return targetImg;
    }
    // 너비, 높이 scale 확인
    CGFloat widthScale = maxSize.width / targetImg.size.width;
    CGFloat heightScale = maxSize.height / targetImg.size.height;
    // 너비, 높이 중 작은 scale에 맞춰서 처리한다.
    CGFloat targetScale = GET_MIN(widthScale,heightScale);
    // max 사이즈보다 원본이 작은 경우 원본을 넘긴다.
    if(targetScale>=1) {
        return targetImg;
    }
    // 이미지 사이즈 줄이기
    CGFloat targetWidth = targetImg.size.width*targetScale;
    CGFloat targetHeight = targetImg.size.height*targetScale;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, targetHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, targetWidth, targetHeight), [targetImg CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// 이미지의 용량을 조절
+(NSData *)revolumeImage:(UIImage *)targetImg maxVolume:(CGFloat)maxVolume {
    CGFloat compressQuality = 1.0f;
    NSData *imageData = UIImageJPEGRepresentation(targetImg, compressQuality);
    NSInteger fileSize = imageData.length;
    NSLog(@">>>>>>>>>> 원본 이미지 용량 체크 : %ld", (long)fileSize);
    while (fileSize>maxVolume & compressQuality>0) // 무한 루프 방지를 위해 compressQuality>0 추가
    {
        compressQuality -= 0.1;
        imageData = UIImageJPEGRepresentation(targetImg, compressQuality);
        fileSize = imageData.length;
        NSLog(@">>>>>>>>>> compress 이미지 용량 체크 : %ld", (long)fileSize);
    }
    return imageData;
}
    
// array을 json 변환
+(NSString *)makeJsonWithArray:(NSArray *)infoArray {
    if(!infoArray) {
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoArray options:0 error:nil];
    if(!jsonData) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
    
// dic을 json 변환
+(NSString *)makeJsonWithDic:(NSDictionary *)infoDic {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDic
                                                       options:0
                                                         error:&err];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        if(err) NSLog(@">>>>>>>>> %s: error: %@", __func__, err.localizedDescription);
        return @"";
    }
}

// 테스트 json 파일로 부터 dic 반환
+(NSDictionary *)loadTestJson:(NSString *)fileNm {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileNm ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSError *err;
    NSDictionary *loadedConvData = [NSJSONSerialization JSONObjectWithData:dataFromFile options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return @{};
    }
    return loadedConvData;
}

// 테스트 json 파일로 부터 스트링 반환
+(NSString *)loadTestString:(NSString *)fileNm {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileNm ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    return [[NSString alloc] initWithData:dataFromFile encoding:NSUTF8StringEncoding];
}

// 컬러 이미지 만들기
+(UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, width));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// 백버튼 가져오기
+(UIButton *)loadBackButton
{
    UIImage *image = [UIImage imageNamed:@"prev"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [btn setImage:image forState:UIControlStateNormal];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
    return btn;
}

// 픽셀 단위 구하기
+(CGFloat)reflectNativeScale:(CGFloat)f {
    CGFloat nativeScale = [UIScreen mainScreen].scale;
    if([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]){
        nativeScale = [UIScreen mainScreen].nativeScale;
    }
    if (f && nativeScale) {
        return f/nativeScale;
    }
    return 0;
}

// 스트링 dictionary로 변환
+(NSDictionary *)jsonStrToDic:(NSString *)jsonTxt {
    NSString *jsonStr = @"";
    @try {
        jsonStr = [jsonTxt stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *loadedConvData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
    if (err) {
        NSLog(@">>>>>>>>>> JSON 파싱에러 : %@", err.description);
        return @{};
    }
    return loadedConvData;
}

// 라벨의 높이 구하기
+ (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

// attributed string 높이 구하기
+ (CGFloat)getAttrStrHeight:(NSMutableAttributedString *)attrStr labelWidth:(CGFloat)labelWidth
{
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(labelWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height;
}

// 이미지 90도 회전
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
+ (UIImage *)rotateImageReverse90:(UIImage *)img
{
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRotateCTM (context, DEGREES_TO_RADIANS(90));
    CGContextTranslateCTM (context, 0, -height);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}


// url호출시 params를 dic에 key/value로 담는다.
+ (NSDictionary *)parseUrlQuery:(NSString *)query
{
    NSMutableDictionary *dict = NSMutableDictionary.new;
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
        NSString *val = [[pair stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@=",[elements objectAtIndex:0]] withString:@""] stringByRemovingPercentEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}

// label의 너비를 구한다.
+ (CGFloat)getLabelWidth:(UILabel*)label
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, label.frame.size.height);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.width;
}

// text의 너비를 구한다.
+ (CGFloat)getTextWidth:(NSString*)text height:(CGFloat)height font:(UIFont*)font
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, height);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.width;
}

// 사진 회전하기
+(UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

// 사진 사이즈와 용량 조절 - MAX_PIC_SIZE, 품질 0.9
+(NSData *)resizeImage:(UIImage*)image IsPNG:(BOOL)isPNG {
    
    // 이미지가 nil인 경우
    if(!image) return nil;
    
    CGFloat actualHeight = image.size.height;
    CGFloat actualWidth = image.size.width;
    
    // 이미지 길이가 0인 경우
    if(actualHeight == 0 || actualWidth == 0) return nil;
    
    CGRect resizeRect;
    // 세로 사진
    if (actualHeight > actualWidth) {
        // 실물 사진이 max보다 큰 경우
        if(actualHeight > MAX_PIC_SIZE) {
            resizeRect = CGRectMake(0.0, 0.0, actualWidth * MAX_PIC_SIZE / actualHeight, MAX_PIC_SIZE);
        }
        // 실물 사진이 max보다 작은 경우
        else {
            resizeRect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        }
    }
    // 가로 사진
    else {
        // 실물 사진이 max보다 큰 경우
        if(actualWidth > MAX_PIC_SIZE) {
            resizeRect = CGRectMake(0.0, 0.0, MAX_PIC_SIZE, actualHeight * MAX_PIC_SIZE / actualWidth);
        }
        // 실물 사진이 max보다 작은 경우
        else {
            resizeRect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        }
    }
    
    UIGraphicsBeginImageContext(resizeRect.size);
    [image drawInRect:resizeRect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *imgData = nil;
    if(isPNG) {
        imgData = UIImagePNGRepresentation(img);
    } else {
        imgData = UIImageJPEGRepresentation(img, COMPRESS_QUALITY_JPEG);
        // 목표 사진 사이즈가 있는 경우 처리
//        while (imgData.length >= MAX_RESIZED_IMG_LEN && compressQuality > 0.1) {
//            compressQuality -= 0.1;
//            imgData = UIImageJPEGRepresentation(img, compressQuality);
//        }
    }
    UIGraphicsEndImageContext();
    
//    UIImage *resizedImg = [UIImage imageWithData:imgData];
//    NSLog(@">>>>>>>> resized imgData length : %lu, size : (%f, %f)", (unsigned long)[imgData length], resizedImg.size.width, resizedImg.size.height);
    return imgData;
}

// UIView 캡쳐
+(NSData *)imageDtWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 이미지가 nil인 경우
    if(img) {
        return UIImageJPEGRepresentation(img, 1.0);
    } else {
        return nil;
    }
}

@end
