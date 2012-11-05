//
//  NLPurchasesManager.h
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-05.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "IAPHelper.h"

#define ALL_WORDS_PURCHASE_IDENTIFIER @"nlauer.LetterpressSolver.AllWords"

@interface NLPurchasesManager : IAPHelper

+ (NLPurchasesManager *)sharedInstance;

@end
