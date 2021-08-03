//
//  UIView(CustomConstraint).h
//  YapYouke
//
//  Created by KimJongmo on 2015. 7. 17..
//  Copyright (c) 2015년 Yap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CustomConstraint)

-(void)fill_parent;
-(void)fill_parent_width;
-(void)fill_parent_height;

-(void)alignToRightOf:(UIView*)to;
-(void)alignToLeftOf:(UIView*)to;
-(void)alignToRightOf:(UIView*)to margin:(CGFloat)margin;
-(void)alignToLeftOf:(UIView*)to margin:(CGFloat)margin;

-(void)alignToTopOf:(UIView*)to;
-(void)alignToBottomOf:(UIView*)to;
-(void)alignToTopOf:(UIView*)to margin:(CGFloat)margin;
-(void)alignToBottomOf:(UIView*)to margin:(CGFloat)margin;

-(void)BottomSpaceOf:(UIView*)to margin:(CGFloat)c;
-(void)TopSpaceOf:(UIView*)to margin:(CGFloat)c;

-(void)CenterHoriOf:(UIView*)to;
-(void)CenterVertiOf:(UIView*)to;
-(void)CenterHoriOf:(UIView*)to margin:(CGFloat)margin;
-(void)CenterVertiOf:(UIView*)to margin:(CGFloat)margin;

-(void)belowTo:(UIView*)to margin:(CGFloat)margin;
-(void)aboveTo:(UIView*)to margin:(CGFloat)margin;

-(void)TopSpaceParent:(CGFloat)c;
-(void)BottomSpaceParent:(CGFloat)c;
-(void)LeadingParent:(CGFloat)c;
-(void)TrailingParent:(CGFloat)c;

-(void)LeadingMargin:(CGFloat)c to:(UIView*)v;
-(void)TrailingMargin:(CGFloat)c to:(UIView*)v;
-(void)TopSpaceMargin:(CGFloat)c to:(UIView*)v;
-(void)BottomSpaceMargin:(CGFloat)c to:(UIView*)v;

-(void)EqualHeight:(UIView*)to;
-(void)EqualWidth:(UIView*)to;

-(void)EqualHeight:(UIView*)to multiplier:(CGFloat)multiplier;
-(void)EqualWidth:(UIView*)to multiplier:(CGFloat)multiplier;

-(void)FixWidth:(CGFloat)c;
-(NSLayoutConstraint *)FixHeiht:(CGFloat)c;

-(void)FixHeihtMultiplier:(CGFloat)m constant:(CGFloat)c;
-(void)FixWidthMultiplier:(CGFloat)m constant:(CGFloat)c;

-(void)setWidthFromHeight:(CGFloat)m;
-(void)setHeightFromWidth:(CGFloat)m;

-(void)CenterInVertical;
-(void)CenterInHori;

-(void)asceptRatioHeightFromWidthMultiplier:(CGFloat)m constant:(CGFloat)c;
-(void)asceptRatioWidthFromHeightMultiplier:(CGFloat)m constant:(CGFloat)c;

-(void)centerInHoriMargin:(CGFloat)margin;
-(void)centerInVerticalMagin:(CGFloat)margin;

@end
