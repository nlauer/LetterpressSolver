//
//  UIColor+Equal.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-16.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "UIColor+Equal.h"

@implementation UIColor (Equal)

- (BOOL)isEqualToColor:(UIColor *)color
{
    float red = 0, green = 0, blue = 0, alpha = 0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    
    float colorRed = 0, colorGreen = 0, colorBlue = 0, colorAlpha = 0;
    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [color getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
    }
    
    BOOL returnVal = red - colorRed < 0.01 && green - colorGreen < 0.01 && blue - colorBlue < 0.01 && alpha - colorAlpha < 0.01;
    return returnVal;
}

@end
