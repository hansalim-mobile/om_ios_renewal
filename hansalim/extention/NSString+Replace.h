//
//  NSString+Replace.h
//  cbncc
//
//  Created by Laone Creative Co.,Ltd. on 2015. 9. 11..
//  Copyright (c) 2015년 SAMSUNG CARD.,LTD. All rights reserved.
//

@interface NSString (ChnXSSUtil)
- (NSString *)XSSDecode;
- (NSString *)XSSDecodeEx;
- (NSString *)jsonEscape;
//- (NSString*)encodedURLParameterString;
@end

@interface NSString (Localized)
- (NSString *)localized;
@end
