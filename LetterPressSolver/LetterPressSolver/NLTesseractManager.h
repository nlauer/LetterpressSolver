//
//  NLTesseractManager.h
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLResultsViewController.h"

typedef void (^TesseractCompletitonBlock)(BOOL success, NSArray *words);

@interface NLTesseractManager : NSObject

+ (NLTesseractManager *)sharedInstance;
- (void)setupTesseract;
- (void)getPossibleWordsFromImage:(UIImage *)image withCompletion:(TesseractCompletitonBlock)completionBlock andDismissViewController:(NLResultsViewController *)dismissViewController;

@end
