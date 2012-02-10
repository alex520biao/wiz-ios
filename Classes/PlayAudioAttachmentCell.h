//
//  PlayAudioAttachmentCell.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> 
@interface PlayAudioAttachmentCell : UITableViewCell
{
    UISlider* processSlider;
    UILabel* currentLabel;
    UIButton* playOrpauseButton;
    UILabel* attachmentNameLabel;
    NSString* audioFilePath;
    AVAudioPlayer* player;
    NSTimer* timer;
    BOOL isPlaying;
    id owner;
}
@property (nonatomic, retain)  UISlider* processSlider;
@property (nonatomic, retain) UILabel* currentLabel;
@property (nonatomic, retain) UIButton* playOrPauseButton;
@property (nonatomic, retain) UILabel* attachmentNameLabel;
@property (nonatomic, retain) NSString* audioFilePath;
@property (nonatomic, retain) AVAudioPlayer* player;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) id owner;
@property (assign) BOOL isPlaying;
- (void) updateMeters;
-(void) addSelcetorToView:(SEL)sel :(UIView*)view;

-(void) prepareForPlay;

- (void) play;

- (void) stop;

@end
