//
//  NLResultsViewController.h
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

- (void)receiveWords:(NSArray *)words;
- (id)initWithBoardImage:(UIImage *)boardImage;

@end
