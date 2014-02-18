//
//  BNCHAdvertViewController.m
//  SampleApp
//
//  Created by Igor Parfenov on 10.02.14.
//  Copyright (c) 2014 Bunch. All rights reserved.
//

#import "BNCHAdvertViewController.h"

@implementation BNCHAdvertViewController

@synthesize webView     = _webView;
@synthesize urlToLoad   = _urlToLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@ web view %@", NSStringFromSelector(_cmd),_urlToLoad);
    [_webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString: _urlToLoad]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
