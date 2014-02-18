//
//  BNCHViewController.h
//  SampleApp
//
//  Created by Igor Parfenov on 09.02.14.
//  Copyright (c) 2014 Bunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNCHViewController : UIViewController


@property (nonatomic)   IBOutlet UIButton*  startButton;
@property (nonatomic)   IBOutlet UILabel*   actionNameLabel;


-(IBAction)onStart:(id)sender;

@end
