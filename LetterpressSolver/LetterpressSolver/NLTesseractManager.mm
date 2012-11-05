//
//  NLTesseractManager.m
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLTesseractManager.h"
#import "baseapi.h"
#import "GPUImage.h"
#include <math.h>

#define MAX_WORD_RETURN_COUNT 2500

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation NLTesseractManager {
    UIImage *image_;
    TesseractCompletitonBlock completionBlock_;
    NLResultsViewController *dismissViewOnFailure_;
    TessBaseAPI *tess;
}

#pragma mark -
#pragma mark Shared Instance
static NLTesseractManager *sharedInstance = NULL;

+ (NLTesseractManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLTesseractManager alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -
#pragma mark Tesseract Setup

- (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return documentsDirectoryPath;
}

- (void)setupTesseract
{
    //code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
    
	NSString *dataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tessdata"];
	/*
	 Set up the data in the docs dir
	 want to copy the data to the documents folder if it doesn't already exist
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:dataPath]) {
		// get the path to the app bundle (with the tessdata dir)
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
		if (tessdataPath) {
			[fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
		}
	}
	
	NSString *dataPathWithSlash = [[self applicationDocumentsDirectory] stringByAppendingString:@"/"];
	setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
	
	// init the tesseract engine.
	tess = new TessBaseAPI();
	
	tess->SimpleInit([dataPath cStringUsingEncoding:NSUTF8StringEncoding],  // Path to tessdata-no ending /.
					 "eng",  // ISO 639-3 string or NULL.
					 false);
}

#pragma mark -
#pragma mark Finding Possible Words

- (void)getPossibleWordsFromImage:(UIImage *)image withCompletion:(TesseractCompletitonBlock)completionBlock andDismissViewController:(NLResultsViewController *)dismissViewController
{
    image_ = image;
    completionBlock_ = completionBlock;
    dismissViewOnFailure_ = dismissViewController;
    
    [self performSelectorInBackground:@selector(startOCRInBackground) withObject:nil];
}

- (NSDictionary *)getLetterCountDictionary:(NSString *)word
{
    NSMutableDictionary *letterCounts = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < word.length; i++) {
        NSNumber *currentChar = [NSNumber numberWithChar:[word characterAtIndex:i]];
        if (![letterCounts objectForKey:currentChar]) {
            [letterCounts setObject:[NSNumber numberWithInt:1] forKey:currentChar];
        } else {
            int newCount = [[letterCounts objectForKey:currentChar] intValue] + 1;
            [letterCounts setObject:[NSNumber numberWithInt:newCount] forKey:currentChar];
        }
    }
    
    return letterCounts;
}

- (BOOL)isLetterCountValid:(NSDictionary *)dictionary withDictionary:(NSDictionary *)checkDictionary
{
    for (NSNumber *key in [dictionary allKeys]) {
        int firstDictCount = [[dictionary objectForKey:key] intValue];
        int secondDictCount = [[checkDictionary objectForKey:key] intValue];
        if (firstDictCount > secondDictCount) {
            return false;
        }
    }
    
    return true;
}

- (void)getPossibleMatchesFromLettersInString:(NSString *)possibleLetters
{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"words" ofType:@"plist"];
    NSArray *words = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray *matchedWords = [[NSMutableArray alloc] init];
    
    NSDictionary *possibleLetterCounts = [self getLetterCountDictionary:possibleLetters];
    
    for (NSString *string in words) {
        NSCharacterSet *notAllowed = [[NSCharacterSet
                                       characterSetWithCharactersInString:possibleLetters] invertedSet];
        NSRange range = [string rangeOfCharacterFromSet:notAllowed];
        BOOL unauthorized = (range.location != NSNotFound);
        if (!unauthorized && [self isLetterCountValid:[self getLetterCountDictionary:string] withDictionary:possibleLetterCounts]) {
            [matchedWords addObject:string];
        }
        
        if ([matchedWords count] > MAX_WORD_RETURN_COUNT) {
            break;
        }
    }
    
    BOOL success = ([matchedWords count] > 0);
    completionBlock_(success, matchedWords);
    completionBlock_ = nil;
    image_ = nil;
    dismissViewOnFailure_ = nil;
}

#pragma mark -
#pragma mark OCR Methods
//http://www.iphonedevsdk.com/forum/iphone-sdk-development/7307-resizing-photo-new-uiimage.html#post33912
-(UIImage *)resizeImage:(UIImage *)image {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	int width, height;
	
	width = 640;//[image size].width;
	height = 640;//[image size].height;
	
	CGContextRef bitmap;
	
	if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	}
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;
}

- (NSString *)getOCRTextFromImage:(UIImage *)uiImage
{
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
	
	CGSize imageSize = [uiImage size];
	double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
	double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
	const UInt8 *imageData = CFDataGetBytePtr(data);
	
	// this could take a while. maybe needs to happen asynchronously.
	char* text = tess->TesseractRect(imageData,(int)bytes_per_pixel,(int)bytes_per_line, 0, 0,(int) imageSize.height,(int) imageSize.width);
    
	return [[[[NSString stringWithCString:text encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] lowercaseString];
}

- (void)startOCRInBackground
{
    // Crop the image to only include the board of letters
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0.3, 1, 0.7)];
    image_ = [cropFilter imageByFilteringImage:image_];
    
    // Resize the image for OCR
	image_ = [self resizeImage:image_];
    
    // Make the image black and white to improve OCR reading
    GPUImageAverageLuminanceThresholdFilter *grayscaleFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
    [grayscaleFilter setThresholdMultiplier:0.5];
    image_ = [grayscaleFilter imageByFilteringImage:image_];
    
    NSString *letters = [self getOCRTextFromImage:image_];
    BOOL success = (letters.length == 25);
    
    if (!success) {
        [self performSelectorOnMainThread:@selector(unsuccessfulScan) withObject:nil waitUntilDone:YES];
        completionBlock_ = nil;
        image_ = nil;
        dismissViewOnFailure_ = nil;
    } else {
        [self getPossibleMatchesFromLettersInString:letters];
    }
}

- (void)unsuccessfulScan
{
    UIAlertView *improperImageAlert = [[UIAlertView alloc] initWithTitle:@"Unrecognized Image" message:@"The image could not be scanned for letters. Make sure your Letterpress is using the default \"Light\" theme before taking the screenshot." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [improperImageAlert show];
    [dismissViewOnFailure_ dismissModalViewControllerAnimated:YES];
}

@end
