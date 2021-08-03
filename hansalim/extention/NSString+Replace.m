//
//  NSString+Replace.m
//  cbncc
//
//  Created by Laone Creative Co.,Ltd. on 2015. 9. 11..
//  Copyright (c) 2015년 SAMSUNG CARD.,LTD. All rights reserved.
//

#import "NSString+Replace.h"

@implementation NSString (ChnXSSUtil)

- (NSString *)XSSDecode
{
	NSMutableString*	replace	= [NSMutableString stringWithString: self];
	[replace replaceOccurrencesOfString: @"&#x27;" withString: @"'"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
	[replace replaceOccurrencesOfString: @"&amp;" withString: @"&"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
	[replace replaceOccurrencesOfString: @"&quot;" withString: @"\""  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
	[replace replaceOccurrencesOfString: @"&lt;" withString: @"<"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
	[replace replaceOccurrencesOfString: @"&gt;" withString: @">"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
	[replace replaceOccurrencesOfString: @"&#x2F;" withString: @"/"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];

	return replace;
}

- (NSString *)XSSDecodeEx
{
    NSMutableString *replace = [NSMutableString stringWithString:self];
    [replace replaceOccurrencesOfString: @"&#xB7;" withString: @"·"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x3E;" withString: @">"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x3D;" withString: @"="  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x3C;" withString: @"<"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x2F;" withString: @"/"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x2D;" withString: @"-"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x29;" withString: @")"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x28;" withString: @"("  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x27;" withString: @"'"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x25;" withString: @"%"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x24;" withString: @"$"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x22;" withString: @"\""  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x21" withString: @"!"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x20;" withString: @" "  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x26;" withString: @"&amp;"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&#x23;" withString: @"#"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&amp;" withString: @"&"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&quot;" withString: @"\""  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&apos;" withString: @"\'"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&amp;" withString: @"&"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&lt;" withString: @"<"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&gt;" withString: @">"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"&middot;" withString: @"·"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];

    return replace;
}

- (NSString *)jsonEscape
{
    NSMutableString*    replace    = [NSMutableString stringWithString: self];
    [replace replaceOccurrencesOfString: @"\\" withString: @"\\\\"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"\n" withString: @"\\\\n"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    [replace replaceOccurrencesOfString: @"\r" withString: @"\\\\r"  options: NSCaseInsensitiveSearch range: NSMakeRange(0, [replace length])];
    return replace;
}

//- (NSString*) encodedURLParameterString {
//    NSString* result =
//    (__bridge_transfer NSString *)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                           (__bridge CFStringRef)self,
//                                                                           NULL,
//                                                                           CFSTR(":/=,!$&'()*+;[]@#?"),
//                                                                           kCFStringEncodingUTF8));
//    return result;
//}

@end

@implementation NSString (Localized)
- (NSString *)localized
{
    //    return NSLocalizedString(self, nil);
    return NSLocalizedStringFromTable(self, @"LocalString", nil);
}
@end
