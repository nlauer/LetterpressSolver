//
//  NLPurchasesManager.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-05.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLPurchasesManager.h"

@implementation NLPurchasesManager

+ (NLPurchasesManager *)sharedInstance
{
    static dispatch_once_t once;
    static NLPurchasesManager * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      ALL_WORDS_PURCHASE_IDENTIFIER,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
