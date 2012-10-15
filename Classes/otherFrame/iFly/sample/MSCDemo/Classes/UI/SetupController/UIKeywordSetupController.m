    //
//  UIKeywordSetupController.m
//  MSC20Demo
//
//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import "UIKeywordSetupController.h"

@interface UIKeywordSetupController(Private)


@end

@implementation UIKeywordSetupController

- (id)initWithRecognize:(IFlyRecognizeControl *)iFlyRecognizeControl
{
	if (self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = TITLE;
		_iFlyRecognizeControl = [iFlyRecognizeControl retain]; 
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark 
#pragma mark 内部调用

- (void)vadValueChanged
{
	if(_vadSwitch.on == YES)
	{
		[_iFlyRecognizeControl setVAD:YES];
	}
	else 
	{
		[_iFlyRecognizeControl setVAD:NO];
	}
	
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// 合成背景音
/*	UILabel *vadLabel = [[UILabel alloc] initWithFrame:H_VAD_LABEL_FRAME];
	vadLabel.text = @"启动断点检测:";
	vadLabel.backgroundColor = [UIColor clearColor];
	vadLabel.font = [UIFont systemFontOfSize:20.0f];
	vadLabel.textColor = [UIColor whiteColor];
	vadLabel.textAlignment = UITextAlignmentLeft;
	[self.view addSubview:vadLabel];
	
	_vadSwitch = [[UISwitch alloc] initWithFrame:H_VAD_SWITCH_FRAME];
	[_vadSwitch setOn:YES animated:NO];
	[_vadSwitch addTarget:self action:@selector(vadValueChanged) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_vadSwitch];*/
}


@end
