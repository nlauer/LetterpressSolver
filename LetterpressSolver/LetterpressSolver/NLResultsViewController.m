//
//  NLResultsViewController.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLResultsViewController.h"

@interface NLResultsViewController ()
@property (strong, nonatomic) NSArray *words;
@end

@implementation NLResultsViewController

@synthesize words = _words;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Results";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void)backButtonPressed
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveWords:(NSArray *)words
{
    _words = words;
    [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_words count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.textLabel.text = [_words objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[[_words objectAtIndex:indexPath.row] length]];
    
    return cell;
}

@end
