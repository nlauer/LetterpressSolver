//
//  NLViewController.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLMainScreenViewController.h"
#import "NLTesseractManager.h"

#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)

@interface NLMainScreenViewController ()

@end

@implementation NLMainScreenViewController {
    UIImagePickerController *imagePickerController_;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initial setup
    [[NLTesseractManager sharedInstance] setupTesseract];
    
    imagePickerController_ = [[UIImagePickerController alloc] init];
    [imagePickerController_ setDelegate:self];
    [imagePickerController_ setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Setup Views
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"Default", @"Default-568h")]]];
    
    UIImage *quickImportImage = [UIImage imageNamed:@"quickImportButton"];
    UIImage *regularImportImage = [UIImage imageNamed:@"regularImportButton"];
    
    UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height/2, self.view.frame.size.width - 60, quickImportImage.size.height*2 + 20)];
    [buttonContainerView setAlpha:0];
    [self.view addSubview:buttonContainerView];
    
    UIButton *quickImportButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, quickImportImage.size.width, quickImportImage.size.height)];
    [quickImportButton setImage:quickImportImage forState:UIControlStateNormal];
    [buttonContainerView addSubview:quickImportButton];
    
    UIButton *regularImportButton = [[UIButton alloc] initWithFrame:CGRectMake(0, quickImportButton.frame.size.height + 20, regularImportImage.size.width, regularImportImage.size.height)];
    [regularImportButton setImage:regularImportImage forState:UIControlStateNormal];
    [regularImportButton addTarget:self action:@selector(regularImportButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:regularImportButton];
    
    [UIView animateWithDuration:0.3 animations:^{
        [buttonContainerView setAlpha:1];
    }];
}

#pragma mark -
#pragma mark Importing Images Methods
- (void)regularImportButtonPressed
{
    [self presentViewController:imagePickerController_ animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[picker dismissModalViewControllerAnimated:YES];
    [[NLTesseractManager sharedInstance] getPossibleWordsFromImage:image withCompletion:^(BOOL success, NSArray *words) {
        if (!success) {
            UIAlertView *improperImageAlert = [[UIAlertView alloc] initWithTitle:@"Unrecognized Image" message:@"The image could not be scanned for letters" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [improperImageAlert show];
        } else {
            NSLog(@"found words:%@", words);
        }
    }];
}

@end
