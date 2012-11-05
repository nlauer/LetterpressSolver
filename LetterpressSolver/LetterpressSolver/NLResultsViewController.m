//
//  NLResultsViewController.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLResultsViewController.h"
#import "NLPurchasesManager.h"

#define NUMBER_OF_REVEALED_WORDS 3
#define LOCK_STRING_LENGTH 8

@interface NLResultsViewController ()
@property (strong, nonatomic) NSArray *words;
@end

@implementation NLResultsViewController {
    int lockedWordsStartIndex_;
    NSArray *products_;
    UIActivityIndicatorView *scanningView_;
}

@synthesize words = _words;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Scanning...";
    lockedWordsStartIndex_ = 0;
    
    [[NLPurchasesManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            products_ = products;
        } else {
            NSLog(@"Failed to find products");
        }
    }];
    
    scanningView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [scanningView_ setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [scanningView_ startAnimating];
    [self.view addSubview:scanningView_];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)backButtonPressed
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)receiveWords:(NSArray *)words
{
    _words = words;
    for (NSString *string in _words) {
        if (string.length > LOCK_STRING_LENGTH) {
            lockedWordsStartIndex_++;
        }
    }
    self.title = @"Results";
    
    [scanningView_ stopAnimating];
    [scanningView_ removeFromSuperview];
    scanningView_ = nil;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44.0f, 44.0f)];
    [backButton setImage:[UIImage imageNamed:@"backArrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)hasAllWordsUnlocked
{
    return [[NLPurchasesManager sharedInstance] productPurchased:ALL_WORDS_PURCHASE_IDENTIFIER];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_words count] > 0) {
        return [self hasAllWordsUnlocked] ? [_words count] : [_words count] - lockedWordsStartIndex_ + NUMBER_OF_REVEALED_WORDS;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell setIndentationLevel:3];
        [cell.textLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([self hasAllWordsUnlocked]) {
        NSString *word = [_words objectAtIndex:indexPath.row];
        cell.textLabel.text = word;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d     ",[word length]];
    } else {
        if (indexPath.row > 2) {
            NSString *word = [_words objectAtIndex:indexPath.row + lockedWordsStartIndex_ + NUMBER_OF_REVEALED_WORDS];
            cell.textLabel.text = word;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d     ",[word length]];
        } else {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            NSString *word = [_words objectAtIndex:indexPath.row];
            cell.textLabel.text = [word stringByReplacingCharactersInRange:NSMakeRange(NUMBER_OF_REVEALED_WORDS-1, word.length-NUMBER_OF_REVEALED_WORDS+1) withString:@"********"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d     ",[word length]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self hasAllWordsUnlocked] && indexPath.row <= NUMBER_OF_REVEALED_WORDS-1) {
        for (SKProduct *product in products_) {
            if ([product.productIdentifier isEqualToString:ALL_WORDS_PURCHASE_IDENTIFIER]) {
                [[NLPurchasesManager sharedInstance] buyProduct:product];
            }
        }
    }
}

@end
