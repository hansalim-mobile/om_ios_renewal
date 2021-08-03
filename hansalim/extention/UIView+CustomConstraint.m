//
//  UIView(CustomConstraint).m
//  YapYouke
//
//  Created by KimJongmo on 2015. 7. 17..
//  Copyright (c) 2015년 Yap. All rights reserved.
//

#import "UIView+CustomConstraint.h"

@implementation UIView (CustomConstraint)

-(void)fill_parent{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self fill_parent_width];
    [self fill_parent_height];
}

-(void)fill_parent_width{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.superview
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0]];
    
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
}


-(void)fill_parent_height{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight   relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeHeight     multiplier:1.f constant:0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY   relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY     multiplier:1.f constant:0]];
}

-(void)alignToRightOf:(UIView*)to {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0]];
}
-(void)alignToLeftOf:(UIView*)to {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeLeading multiplier:1.f constant:0]];
}

-(void)alignToRightOf:(UIView*)to margin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeTrailing multiplier:1.f constant:margin]];
}
-(void)alignToLeftOf:(UIView*)to margin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeLeading multiplier:1.f constant:margin]];
}


-(void)CenterHoriOf:(UIView*)to{
    [self CenterHoriOf:to margin:1.f];
}
-(void)CenterVertiOf:(UIView*)to {
    [self CenterVertiOf:to margin:1.f];
}
-(void)CenterHoriOf:(UIView*)to margin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX        relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeCenterX   multiplier:1.f constant:margin]];
}
-(void)CenterVertiOf:(UIView*)to margin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY        relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeCenterY   multiplier:1.f constant:margin]];
}

-(void)alignToTopOf:(UIView*)to{
    [self alignToTopOf:to margin:0.f];
}
-(void)alignToBottomOf:(UIView*)to{
    [self alignToBottomOf:to margin:0.f];
}

-(void)alignToTopOf:(UIView*)to margin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeTop multiplier:1.f constant:margin]];
}

-(void)alignToBottomOf:(UIView*)to margin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeBottom multiplier:1.f constant:margin]];
}


-(void)TopSpaceOf:(UIView*)to margin:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:to attribute:NSLayoutAttributeBottom
                                                              multiplier:1.f
                                                                constant:c]];
}

-(void)BottomSpaceOf:(UIView*)to margin:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom     relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeTop   multiplier:1.f constant:c]];
}


-(void)LeadingParent:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading   relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeading   multiplier:1.f constant:c]];
}

-(void)TrailingParent:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing   relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTrailing  multiplier:1.f constant:c]];
}

-(void)TopSpaceParent:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop        relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop   multiplier:1.f constant:c]];
}

-(void)BottomSpaceParent:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom     relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom   multiplier:1.f constant:c]];
}



-(void)LeadingMargin:(CGFloat)c to:(UIView*)v{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading   relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeLeading   multiplier:1.f constant:c]];
}

-(void)TrailingMargin:(CGFloat)c to:(UIView*)v{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing   relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTrailing  multiplier:1.f constant:c]];
}

-(void)TopSpaceMargin:(CGFloat)c to:(UIView*)v{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeTopMargin
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:v
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.f
                                                                constant:c]];
}

-(void)BottomSpaceMargin:(CGFloat)c to:(UIView*)v{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottomMargin     relatedBy:NSLayoutRelationEqual toItem:v attribute:NSLayoutAttributeTop   multiplier:1.f constant:c]];
}

-(void)EqualHeight:(UIView*)to{
    [self EqualWidth:to multiplier:1.f];
}

-(void)EqualWidth:(UIView*)to{
    [self EqualWidth:to multiplier:1.f];
}

-(void)EqualHeight:(UIView*)to multiplier:(CGFloat)m{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight   relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeHeight     multiplier:m constant:0]];
}

-(void)EqualWidth:(UIView*)to multiplier:(CGFloat)m{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth   relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeWidth     multiplier:m constant:0]];
}

-(void)FixWidth:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth      relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth     multiplier:1.f constant:c]];
}

-(void)FixWidthMultiplier:(CGFloat)m constant:(CGFloat)c {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth      relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth     multiplier:m constant:c]];
}

-(NSLayoutConstraint *)FixHeiht:(CGFloat)c{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.f
                                                                    constant:c];
    [self.superview addConstraint:constraint];
    return constraint;
}

-(void)FixHeihtMultiplier:(CGFloat)m constant:(CGFloat)c {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight      relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight     multiplier:m constant:c]];
}

-(void)asceptRatioHeightFromWidthMultiplier:(CGFloat)m constant:(CGFloat)c {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight      relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth     multiplier:m constant:c]];
}

-(void)asceptRatioWidthFromHeightMultiplier:(CGFloat)m constant:(CGFloat)c {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight      relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth     multiplier:m constant:c]];
}

-(void)setWidthFromHeight:(CGFloat)m {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:m constant:0]];
}

-(void)setHeightFromWidth:(CGFloat)m {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:m constant:0]];
}

-(void)belowTo:(UIView*)to margin:(CGFloat)margin {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeBottom multiplier:1.f constant:margin]];
}

-(void)aboveTo:(UIView*)to margin:(CGFloat)margin {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:to attribute:NSLayoutAttributeTop multiplier:1.f constant:margin]];
}

-(void)CenterInHori{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX        relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX   multiplier:1.f constant:0]];
}
-(void)CenterInVertical{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY        relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY   multiplier:1.f constant:0]];
}

-(void)centerInHoriMargin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX        relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX   multiplier:1.f constant:margin]];
}
-(void)centerInVerticalMagin:(CGFloat)margin{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY        relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY   multiplier:1.f constant:margin]];
}

@end
