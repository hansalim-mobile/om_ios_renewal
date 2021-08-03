//
//  Util.h
//  hansalim
//
//  Created by NT0154 on 2017. 12. 12..
//  Copyright © 2017년 NT0154. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AqKeychainItemWrapper.h"

@interface Util : NSObject

#pragma mark - Check Network
+ (BOOL)connectedToNetwork;
+ (void)canNotNetwork;
+ (BOOL)pushNotificationsEnabled;

#pragma mark - linkImageDownroad
+ (BOOL) downloadFile:(NSString*)uri;
+ (NSString*) pathForResource:(NSString*)resourcepath;




// WK 캐쉬 삭제
+ (void)removeWkWebCache;

// 공통 formatter
+ (NSDateFormatter *)getDateFormatter;

// 날짜 포멧팅 변경
+(NSString *)changeDateFormat:(NSString *)dateStr oriFormatStr:(NSString *)oriFormatStr targetFormatStr:(NSString *)targetFormatStr;

// udid 가져오기
+ (NSString *)getDeviceUDID;

// uuid 가져오기
+ (NSString *)getDeviceUUID;

// 마이너스 일전 날짜 취득
+(NSDate *)getMinusDayAgoDate:(NSInteger)minusDay;

// 이미지의 사이즈를 조절
+(UIImage *)resizeImage:(UIImage *)targetImg maxSize:(CGSize)maxSize;

// 이미지의 용량을 조절
+(NSData *)revolumeImage:(UIImage *)targetImg maxVolume:(CGFloat)maxVolume;

// 테스트 json 파일로 부터 dic 반환
+(NSDictionary *)loadTestJson:(NSString *)fileNm;

// 테스트 json 파일로 부터 스트링 반환
+(NSString *)loadTestString:(NSString *)fileNm;

// 컬러 이미지 만들기
+(UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)width;

// 백버튼 가져오기
+(UIButton *)loadBackButton;

// dic을 json 변환
+(NSString *)makeJsonWithDic:(NSDictionary *)infoDic;

// 픽셀 단위 구하기
+(CGFloat)reflectNativeScale:(CGFloat)f;

// 스트링 dictionary로 변환
+(NSDictionary *)jsonStrToDic:(NSString *)jsonTxt;

// 라벨의 높이 구하기
+(CGFloat)getLabelHeight:(UILabel*)label;

// attributed string 높이 구하기
+ (CGFloat)getAttrStrHeight:(NSMutableAttributedString *)attrStr labelWidth:(CGFloat)labelWidth;

// 이미지 90도 회전
+ (UIImage *)rotateImageReverse90:(UIImage *)img;

// url호출시 params를 dic에 key/value로 담는다.
+ (NSDictionary *)parseUrlQuery:(NSString *)query;

// label의 너비를 구한다.
+ (CGFloat)getLabelWidth:(UILabel*)label;

// text의 너비를 구한다.
+ (CGFloat)getTextWidth:(NSString*)text height:(CGFloat)height font:(UIFont*)font;

// array을 json 변환
+(NSString *)makeJsonWithArray:(NSArray *)infoArray;

// 사진 회전하기
+(UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise;

// 사진 사이즈와 용량 조절 - MAX_PIC_SIZE, 품질 0.9
+(NSData *)resizeImage:(UIImage*)image IsPNG:(BOOL)isPNG;

// UIView 캡쳐
+(NSData *)imageDtWithView:(UIView *)view;


@end
