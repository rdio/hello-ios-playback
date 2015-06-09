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

@property (strong, nonatomic) IBOutlet UISlider *seekSlider;
@property (strong, nonatomic) IBOutlet UILabel *positionLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) IBOutlet UISlider *leftAudioLevelSlider;
@property (strong, nonatomic) IBOutlet UISlider *rightAudioLevelSlider;

@property (strong, nonatomic) IBOutlet UILabel *sourceNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *albumNameLabel;



- (IBAction)loginTapped:(id)sender;
- (IBAction)playPauseTapped:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)previousButtonTapped:(id)sender;
- (IBAction)stopButtonTapped:(id)sender;

@end

