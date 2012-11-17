//
//  UIImage+RGBA.h
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-11.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GREY_ONE [UIColor colorWithRed:0.913725 green:0.909804 blue:0.898039 alpha:1]
#define GREY_TWO [UIColor colorWithRed:0.901961 green:0.898039 blue:0.886275 alpha:1]
#define LIGHT_BLUE [UIColor colorWithRed:0.470588 green:0.784314 blue:0.960784 alpha:1]
#define DARK_BLUE [UIColor colorWithRed:0 green:0.635294 blue:1 alpha:1]
#define LIGHT_RED [UIColor colorWithRed:0.968627 green:0.6 blue:0.552941 alpha:1]
#define DARK_RED [UIColor colorWithRed:1 green:0.262745 blue:0.184314 alpha:1]

@interface UIImage (RGBA)

- (NSArray*)getColorsAtPoints:(NSArray *)points;

@end
