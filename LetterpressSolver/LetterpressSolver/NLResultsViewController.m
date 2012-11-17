//
//  NLResultsViewController.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLResultsViewController.h"
#import "NLPurchasesManager.h"
#import "NLLetter.h"

#define NUMBER_OF_REVEALED_WORDS MIN(3, [_words count])
#define LOCK_STRING_LENGTH 8

@interface NLResultsViewController ()
@property (strong, nonatomic) UIImage *boardImage;
@property (strong, nonatomic) NSArray *unfilteredWords;
@property (strong, nonatomic) NSMutableArray *words;
@property (strong, nonatomic) UISearchBar *filterSearchBar;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation NLResultsViewController {
    int lockedWordsStartIndex_;
    NSArray *products_;
    UIActivityIndicatorView *scanningView_;
    UIImageView *boardImageView_;
    UIView *scanningOverlay_;
}

@synthesize words = _words, tableView = _tableView, filterSearchBar = _filterSearchBar, unfilteredWords = _unfilteredWords;
@synthesize boardImage = _boardImage;

- (id)initWithBoardImage:(UIImage *)boardImage
{
    self = [super init];
    if (self) {
        _boardImage = boardImage;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"Scanning...";
    lockedWordsStartIndex_ = 0;
    
    if (![self hasAllWordsUnlocked]) {
        [[NLPurchasesManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                products_ = products;
            } else {
                NSLog(@"Failed to find products");
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    
    _filterSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    [_filterSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_filterSearchBar setDelegate:self];
    [_filterSearchBar setPlaceholder:@"Filter with letters.."];
    [_filterSearchBar setHidden:YES];
    
    [self.view addSubview:_filterSearchBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44.0, self.view.frame.size.width, self.view.frame.size.height-88) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    CGPoint centerPoint = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - 44)/2);
    
    boardImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    [boardImageView_ setCenter:centerPoint];
    [boardImageView_ setImage:_boardImage];
    [boardImageView_ setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:boardImageView_];
    
    scanningOverlay_ = [[UIView alloc] initWithFrame:self.view.frame];
    [scanningOverlay_ setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.view addSubview:scanningOverlay_];
    
    scanningView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [scanningView_ setCenter:centerPoint];
    [scanningView_ startAnimating];
    [self.view addSubview:scanningView_];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    scanningView_ = nil;
    boardImageView_ = nil;
    scanningOverlay_ = nil;
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
    _unfilteredWords = words;
    _words = [NSArray arrayWithArray:_unfilteredWords];
    for (NSString *string in _words) {
        if (string.length > LOCK_STRING_LENGTH) {
            lockedWordsStartIndex_++;
        }
    }
    self.title = @"Results";
    
    [boardImageView_ removeFromSuperview];
    boardImageView_ = nil;
    
    [scanningOverlay_ removeFromSuperview];
    scanningOverlay_ = nil;
    
    [scanningView_ stopAnimating];
    [scanningView_ removeFromSuperview];
    scanningView_ = nil;
    
    [_filterSearchBar setHidden:NO];
    
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

- (void)updateWordsWithFilter:(NSString *)filterText
{
    if (filterText) {
        lockedWordsStartIndex_ = 0;
        NSMutableArray *words = [[NSMutableArray alloc] init];
        for (NSString *word in _unfilteredWords) {
            NSString *mutableWord = word;
            BOOL shouldAddWord = TRUE;
            for (int i = 0; i < [filterText length]; i++) {
                NSString *letter = [filterText substringWithRange:NSMakeRange(i, 1)];
                NSRange letterRange = [mutableWord rangeOfString:letter];
                if (letterRange.length == 0) {
                    shouldAddWord = FALSE;
                    break;
                } else {
                    mutableWord = [mutableWord stringByReplacingCharactersInRange:letterRange withString:@""];
                }
            }
            if (shouldAddWord) {
                [words addObject:word];
                if (word.length > LOCK_STRING_LENGTH) {
                    lockedWordsStartIndex_++;
                }
            }
        }
        _words = words;
    } else {
        _words = [NSArray arrayWithArray:_unfilteredWords];
    }
    [self performSelectorOnMainThread:@selector(updateTableViewForNewWords) withObject:nil waitUntilDone:NO];
}

- (void)updateTableViewForNewWords
{
    [_tableView reloadData];
    if ([_words count] > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_words count] > 0) {
        return [self hasAllWordsUnlocked] ? [_words count] : [_words count] <= 3 ? [_words count] : [_words count] - lockedWordsStartIndex_ + NUMBER_OF_REVEALED_WORDS;
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
        int index = indexPath.row + lockedWordsStartIndex_ - NUMBER_OF_REVEALED_WORDS;
        NSString *word;
        if (index < [_words count] && index >= 0) {
            word = [_words objectAtIndex:index];
        }
        if (indexPath.row > 2) {
            cell.textLabel.text = word;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d     ",[word length]];
        } else {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            NSString *word = [_words objectAtIndex:indexPath.row];
            if ([word length] > 8) {
                cell.textLabel.text = [word stringByReplacingCharactersInRange:NSMakeRange(NUMBER_OF_REVEALED_WORDS-1, word.length-NUMBER_OF_REVEALED_WORDS+1) withString:@"********"];
            } else {
                cell.textLabel.text = word;
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d     ",[word length]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self hasAllWordsUnlocked] && indexPath.row <= NUMBER_OF_REVEALED_WORDS-1) {
        if ([products_ count] == 0) {
            [[NLPurchasesManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                if (success) {
                    products_ = products;
                    for (SKProduct *product in products_) {
                        if ([product.productIdentifier isEqualToString:ALL_WORDS_PURCHASE_IDENTIFIER]) {
                            [[NLPurchasesManager sharedInstance] buyProduct:product];
                        }
                    }
                } else {
                    UIAlertView *failedToLoadProducts = [[UIAlertView alloc] initWithTitle:@"Failed to find Purchases" message:@"Please make sure your internet connection is enabled" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [failedToLoadProducts show];
                }
            }];
        } else {
            for (SKProduct *product in products_) {
                if ([product.productIdentifier isEqualToString:ALL_WORDS_PURCHASE_IDENTIFIER]) {
                    [[NLPurchasesManager sharedInstance] buyProduct:product];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)notification
{
    float keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height - keyboardHeight)];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    float keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + keyboardHeight)];
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSelectorInBackground:@selector(updateWordsWithFilter:) withObject:[searchText lowercaseString]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
}

@end
