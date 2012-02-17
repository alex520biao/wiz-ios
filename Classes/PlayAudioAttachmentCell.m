//
//  PlayAudioAttachmentCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlayAudioAttachmentCell.h"
#import "AttachmentsView.h"
#import "WizIndex.h"
@implementation PlayAudioAttachmentCell

@synthesize currentLabel;
@synthesize playOrPauseButton;
@synthesize processSlider;
@synthesize attachmentNameLabel;
@synthesize audioFilePath;
@synthesize player;
@synthesize timer;
@synthesize isPlaying;
@synthesize owner;
- (void) dealloc
{
    self.attachmentNameLabel = nil;
    self.processSlider = nil;
    self.audioFilePath = nil;
    self.playOrPauseButton = nil;
    self.currentLabel = nil;
    self.player = nil;
    self.owner = nil;
    [super dealloc];
}

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playOrPauseButton.frame =  CGRectMake(5, 5, 30, 30);
        [self.playOrPauseButton setImage:[UIImage imageNamed:@"recorderPlay"] forState:UIControlStateNormal];
        [self addSubview:self.playOrPauseButton];
        self.attachmentNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80, -8, 280, 40)] autorelease];
        [self.attachmentNameLabel setFont:[UIFont systemFontOfSize:13]];
        self.attachmentNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.attachmentNameLabel];
        
        self.processSlider = [[[UISlider alloc] initWithFrame:CGRectMake(90, 20, 190, 20)] autorelease];
        [self addSubview:self.processSlider];
        
        self.currentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 20, 50, 20)] autorelease];
        self.currentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.currentLabel];
        self.backgroundColor = [UIColor colorWithRed:101.0/255 green:186.0/255 blue:247.0/255 alpha:0.0f];
    }
    return self;
}

- (void) updateMeters
{
    self.currentLabel.text = [NSString stringWithFormat:@"%@",[WizIndex timerStringFromTimerInver:self.player.currentTime]];
    self.processSlider.value = self.player.currentTime/self.player.duration;
    if (self.processSlider.value == 0) {
        [self stop];
    }
}
-(void) addSelcetorToView:(SEL)sel :(UIView*)view
{
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:sel] autorelease];
    tap.numberOfTapsRequired =1;
    tap.numberOfTouchesRequired =1;
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
}

-(void) prepareForPlay
{
    NSURL* url = [[NSURL alloc] initFileURLWithPath:self.audioFilePath];

    self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil] autorelease];

    [url release];
    [self.player prepareToPlay];
    self.currentLabel.text = [NSString stringWithFormat:@"00:00"];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(280, 20, 40, 20)];
    label.text = [WizIndex timerStringFromTimerInver:self.player.duration];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont systemFontOfSize:13]];
    [self addSubview:label];
    [label release];
    [self.playOrPauseButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) pause
{
    [self.playOrPauseButton setImage:[UIImage imageNamed: @"recorderPause"] forState:UIControlStateNormal];
    [self.timer invalidate];
    [self.player pause];
    [self.playOrPauseButton removeTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
}

- (void) play
{
    if (isPlaying) {
        return;
    }
    [self.player play];
    [self.playOrPauseButton removeTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void) stop
{
    [self.player stop];
    [self.timer invalidate];
    AttachmentsView* base = (AttachmentsView*)self.owner;
    [base audioPlayStop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
