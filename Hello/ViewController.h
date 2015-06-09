//
//  ViewController.h
//  Hello
//
//  Created by Kevin Nelson on 6/9/15.
//  Copyright (c) 2015 Rdio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>

@interface ViewController : UIViewController <RdioDelegate, RDPlayerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;

@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;


- (IBAction)loginTapped:(id)sender;
- (IBAction)playPauseTapped:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)previousButtonTapped:(id)sender;
- (IBAction)stopButtonTapped:(id)sender;

@end

