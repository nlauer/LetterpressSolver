//
//  UIImage+RGBA.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-11.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "UIImage+RGBA.h"

@implementation UIImage (RGBA)

- (NSArray*)getColorsAtPoints:(NSArray *)points
{
    if ([points count] == 0) {
        return nil;
    }
    if (![[points objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        return nil;
    }
    if ([[points objectAtIndex:0] count] != 2) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[points count]];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [self CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    for (NSArray *point in points) {
        int byteIndex = (bytesPerRow * [[point objectAtIndex:1] intValue]) + [[point objectAtIndex:0] intValue] * bytesPerPixel;
        
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
        
    }
    
    free(rawData);
    
    NSLog(@"result:%@", result);
    return result;
}


@end
