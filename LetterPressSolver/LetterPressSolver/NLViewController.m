//
//  NLViewController.m
//  LetterPressSolver
//
//  Created by Nick Lauer on 12-11-03.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import "NLViewController.h"
#import "Tesseract.h"

@interface NLViewController ()

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:[UIImage imageNamed:@"letterpress"]];
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
