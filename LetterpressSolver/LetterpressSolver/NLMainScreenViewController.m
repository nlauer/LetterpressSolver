//
//  NLViewController.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLMainScreenViewController.h"
#import "NLTesseractManager.h"
#import "NLResultsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPUImage.h"

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
    
    imagePickerController_ = [[UIImagePickerController alloc] init];
    [imagePickerController_ setDelegate:self];
    [imagePickerController_ setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Setup Views
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"Default", @"Default-568h")]]];
    
    UIImage *quickImportImage = [UIImage imageNamed:@"quickImportButton"];
    UIImage *regularImportImage = [UIImage imageNamed:@"regularImportButton"];
    
    // Container for the buttons
    UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height/2 - 10, self.view.frame.size.width - 60, quickImportImage.size.height*2 + 20)];
    [buttonContainerView setAlpha:0];
    [self.view addSubview:buttonContainerView];
    
    // Quick Import Button
    UIButton *quickImportButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60, quickImportImage.size.height)];
    [quickImportButton setImageEdgeInsets:UIEdgeInsetsMake(0, -(self.view.frame.size.width - 60)/2 - 27, 0, 0)];
    [quickImportButton setImage:quickImportImage forState:UIControlStateNormal];
    [quickImportButton addTarget:self action:@selector(quickImportButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:quickImportButton];
    
    UILabel *quickImportLabel = [[UILabel alloc] initWithFrame:CGRectMake(quickImportImage.size.width + 10, 20, quickImportButton.frame.size.width - 10 - quickImportImage.size.width, 22)];
    [quickImportLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [quickImportLabel setTextColor:[UIColor blackColor]];
    [quickImportLabel setBackgroundColor:[UIColor clearColor]];
    [quickImportLabel setText:@"Quick Import"];
    [quickImportButton addSubview:quickImportLabel];
    
    UILabel *quickImportDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(quickImportLabel.frame.origin.x, quickImportLabel.frame.origin.y + quickImportLabel.frame.size.height + 5, quickImportButton.frame.size.width - 10 - quickImportImage.size.width, 44)];
    [quickImportDetailLabel setFont:[UIFont systemFontOfSize:14]];
    [quickImportDetailLabel setTextColor:[UIColor blackColor]];
    [quickImportDetailLabel setBackgroundColor:[UIColor clearColor]];
    [quickImportDetailLabel setText:@"Quickly load the last screenshot taken"];
    [quickImportDetailLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [quickImportDetailLabel setNumberOfLines:2];
    [quickImportButton addSubview:quickImportDetailLabel];
    
    // Regular Import Button
    UIButton *regularImportButton = [[UIButton alloc] initWithFrame:CGRectMake(0, quickImportButton.frame.size.height + 20, self.view.frame.size.width - 60, regularImportImage.size.height)];
    [regularImportButton setImageEdgeInsets:UIEdgeInsetsMake(0, -(self.view.frame.size.width - 60)/2 - 27, 0, 0)];
    [regularImportButton setImage:regularImportImage forState:UIControlStateNormal];
    [regularImportButton addTarget:self action:@selector(regularImportButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:regularImportButton];
    
    UILabel *regularImportLabel = [[UILabel alloc] initWithFrame:CGRectMake(regularImportImage.size.width + 10, 20, regularImportButton.frame.size.width - 10 - quickImportImage.size.width, 22)];
    [regularImportLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [regularImportLabel setTextColor:[UIColor blackColor]];
    [regularImportLabel setBackgroundColor:[UIColor clearColor]];
    [regularImportLabel setText:@"Regular Import"];
    [regularImportButton addSubview:regularImportLabel];
    
    UILabel *regularImportDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(regularImportLabel.frame.origin.x, regularImportLabel.frame.origin.y + regularImportLabel.frame.size.height + 5, regularImportButton.frame.size.width - 10 - regularImportImage.size.width, 44)];
    [regularImportDetailLabel setFont:[UIFont systemFontOfSize:14]];
    [regularImportDetailLabel setTextColor:[UIColor blackColor]];
    [regularImportDetailLabel setBackgroundColor:[UIColor clearColor]];
    [regularImportDetailLabel setText:@"Select a screenshot to use"];
    [regularImportDetailLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [regularImportDetailLabel setNumberOfLines:2];
    [regularImportButton addSubview:regularImportDetailLabel];
    
    [UIView animateWithDuration:0.3 animations:^{
        [buttonContainerView setAlpha:1];
    }];
}

#pragma mark -
#pragma mark Importing Images Methods

- (void)quickImportButtonPressed
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets]-1]
                                options:0
                             usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                 
                                 // The end of the enumeration is signaled by asset == nil.
                                 if (alAsset) {
                                     ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                     UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                                     
                                     float screenHeight = [[UIScreen mainScreen] bounds].size.height;
                                     // Crop the image to only include the board of letters
                                     GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, (screenHeight-320.0f)/screenHeight, 1, 320.0/screenHeight)];
                                     UIImage *croppedImage = [cropFilter imageByFilteringImage:latestPhoto];
                                     
                                     NLResultsViewController *resultsViewController = [[NLResultsViewController alloc] initWithBoardImage:croppedImage];
                                     
                                     [resultsViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                                     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:resultsViewController];
                                     
                                     [self presentModalViewController:navigationController animated:YES];
                                     
                                     [[NLTesseractManager sharedInstance] getPossibleWordsFromImage:croppedImage withCompletion:^(BOOL success, NSArray *words) {
                                         [resultsViewController performSelectorOnMainThread:@selector(receiveWords:) withObject:words waitUntilDone:YES];
                                     } andDismissViewController:resultsViewController];
                                 }
                             }];
    }
                         failureBlock: ^(NSError *error) {
                             // Typically you should handle an error more gracefully than this.
                             UIAlertView *noImagesAlert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful" message:@"Check to make sure you have given Location and/or Photo permissions to this app" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                             [noImagesAlert show];
                         }];
}

- (void)regularImportButtonPressed
{
    [self presentViewController:imagePickerController_ animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    // Crop the image to only include the board of letters
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, (screenHeight-320.0f)/screenHeight, 1, 320.0/screenHeight)];
    UIImage *croppedImage = [cropFilter imageByFilteringImage:image];
    
    NLResultsViewController *resultsViewController = [[NLResultsViewController alloc] initWithBoardImage:croppedImage];
    [resultsViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:resultsViewController];
    
	[picker dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:navigationController animated:YES completion:^{
            [[NLTesseractManager sharedInstance] getPossibleWordsFromImage:croppedImage withCompletion:^(BOOL success, NSArray *words) {
                [resultsViewController performSelectorOnMainThread:@selector(receiveWords:) withObject:words waitUntilDone:YES];
            } andDismissViewController:resultsViewController];
        }];
    }];
}

@end
