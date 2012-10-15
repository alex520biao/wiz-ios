    //
//  UISynthesizerSetupController.m
//  MSC20Demo

//  description: you can setup the synthesizercontroller 

//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

// 本接口主要实现了对语音合成控件的设置，
#import "UISynthesizerSetupController.h"

@interface UISynthesizerSetupController(Private)

- (void)bgSwitchValueChanged;

- (void)personVoiceSegValueChanged;

- (void)speedValueChanged;

- (void)volumeValueChanged;

@end

@implementation UISynthesizerSetupController

- (id)initWithSynthesizer:(IFlySynthesizerControl *)iFlySynthesizerControl
{
	if (self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = TITLE;
		_iFlySynthesizerControl = [iFlySynthesizerControl retain];
	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark 
#pragma mark 内部调用

//  set whether to show UI
//  设置是否显示UI
- (void)synthesizerUIChanged
{
	if(_synthesizerUISwitch.on == YES)
	{
        
		[_iFlySynthesizerControl setShowUI:YES];
	}
	else 
	{
		[_iFlySynthesizerControl setShowUI:NO];
	}

}

// set whether have the background music
// 设置合成过程中是否有背景音乐
- (void)bgSwitchValueChanged
{
	if(_bgVoiceSwitch.on == YES)
	{
		[_iFlySynthesizerControl setBackgroundSound:@"liangzhu"];
	}
	else 
	{
		[_iFlySynthesizerControl setBackgroundSound:@""];
	}
	
}

// set the pronunciation people
// 设置发音人
- (void)personVoiceSegValueChanged
{
	if(_personVoiceSegment.selectedSegmentIndex == 0)
	{
		[_iFlySynthesizerControl setVoiceName:@"xiaoyu"];
	}
	else 
	{
		[_iFlySynthesizerControl setVoiceName:@"xiaoyan"];
	}
}

// set the voice speed
// 设置语速
- (void)speedValueChanged
{
	NSLog(@"speed:%d",_speedVoiceSlider.value);
	[_iFlySynthesizerControl setSpeed:_speedVoiceSlider.value];
}

// set the volume
// 设置音量
- (void)volumeValueChanged
{
	[_iFlySynthesizerControl setVolume:_volumeVoiceSlider.value];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // 配置合成设置界面
	
	// 显示合成界面 0
	_synthesizerUILabel = [[UILabel alloc] initWithFrame:H_UI_LABEL_FRAME];
	_synthesizerUILabel.text = @"显示合成界面:";
	_synthesizerUILabel.backgroundColor = [UIColor clearColor];
	_synthesizerUILabel.font = [UIFont systemFontOfSize:20.0f];
	_synthesizerUILabel.textColor = [UIColor blackColor];
	_synthesizerUILabel.textAlignment = UITextAlignmentLeft;
	//[self.view addSubview:synthesizerUILabel];
	
	_synthesizerUISwitch = [[UISwitch alloc] initWithFrame:H_UI_CONTEXT_FRAME];
	[_synthesizerUISwitch addTarget:self action:@selector(synthesizerUIChanged) forControlEvents:UIControlEventValueChanged];
	[_synthesizerUISwitch setOn:YES];
	//[self.view addSubview:_synthesizerUISwitch];
	
	// 合成背景音 1
	_bgVoiceLabel = [[UILabel alloc] initWithFrame:H_UI_LABEL_FRAME];
	_bgVoiceLabel.text = @"合成背景音:";
	_bgVoiceLabel.backgroundColor = [UIColor clearColor];
	_bgVoiceLabel.font = [UIFont systemFontOfSize:20.0f];
	_bgVoiceLabel.textColor = [UIColor blackColor];
	_bgVoiceLabel.textAlignment = UITextAlignmentLeft;
	//[self.view addSubview:_bgVoiceLabel];
	
	_bgVoiceSwitch = [[UISwitch alloc] initWithFrame:H_UI_CONTEXT_FRAME];
	[_bgVoiceSwitch addTarget:self action:@selector(bgSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
	//[self.view addSubview:_bgVoiceSwitch];
	
	// 发音人 2
	_personVoiceLabel = [[UILabel alloc] initWithFrame:H_UI_LABEL_FRAME];
	_personVoiceLabel.text = @"选择发音人:";
	_personVoiceLabel.backgroundColor = [UIColor clearColor];
	_personVoiceLabel.font = [UIFont systemFontOfSize:20.0f];
	_personVoiceLabel.textColor = [UIColor blackColor];
	_personVoiceLabel.textAlignment = UITextAlignmentLeft;
	//[self.view addSubview:_personVoiceLabel];
	
	NSArray *array = [[NSArray alloc] initWithObjects:@"男",@"女",nil];
	_personVoiceSegment = [[UISegmentedControl alloc] initWithItems:array];
	_personVoiceSegment.frame = H_UI_CONTEXT_FRAME;
	
	[_personVoiceSegment addTarget:self action:@selector(personVoiceSegValueChanged) forControlEvents:UIControlEventValueChanged];
	_personVoiceSegment.selectedSegmentIndex = 1;
	//[self.view addSubview:_personVoiceSegment];
	
	
	
	// 语速 3
	_speedVoiceLabel = [[UILabel alloc] initWithFrame:H_UI_LABEL_FRAME];
	_speedVoiceLabel.text = @"语速:";
	_speedVoiceLabel.backgroundColor = [UIColor clearColor];
	_speedVoiceLabel.font = [UIFont systemFontOfSize:20.0f];
	_speedVoiceLabel.textColor = [UIColor blackColor];
	_speedVoiceLabel.textAlignment = UITextAlignmentLeft;
	//[self.view addSubview:_speedVoiceLabel];
	
	_speedVoiceSlider = [[UISlider alloc] initWithFrame:H_UI_CONTEXT_FRAME];
	_speedVoiceSlider.minimumValue = 1;  
	_speedVoiceSlider.maximumValue = 5;
	_speedVoiceSlider.value = 3;
	[_speedVoiceSlider addTarget:self action:@selector(speedValueChanged) forControlEvents:UIControlEventValueChanged];
	
	//[self.view addSubview:_speedVoiceSlider];
	
	// 音量
	_volumeVoiceLabel = [[UILabel alloc] initWithFrame:H_UI_LABEL_FRAME];
	_volumeVoiceLabel.text = @"音量:";
	_volumeVoiceLabel.backgroundColor = [UIColor clearColor];
	_volumeVoiceLabel.font = [UIFont systemFontOfSize:20.0f];
	_volumeVoiceLabel.textColor = [UIColor blackColor];
	_volumeVoiceLabel.textAlignment = UITextAlignmentLeft;
	//[self.view addSubview:_volumeVoiceLabel];
	
	_volumeVoiceSlider = [[UISlider alloc] initWithFrame:H_UI_CONTEXT_FRAME];
	_volumeVoiceSlider.minimumValue = 1;  
	_volumeVoiceSlider.maximumValue = 100;
	_volumeVoiceSlider.value = 50;
	[_volumeVoiceSlider addTarget:self action:@selector(volumeValueChanged) forControlEvents:UIControlEventValueChanged];
	
	[self bgSwitchValueChanged];
	[self personVoiceSegValueChanged];
	[self speedValueChanged];
	[self volumeValueChanged];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    }
	
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	// Configure the cell.

	//[self.view addSubview:_volumeVoiceSlider];
	

	switch (indexPath.row)
	{
		case 0:
		{
			// 0
			[cell addSubview:_synthesizerUILabel];
			[cell addSubview:_synthesizerUISwitch];
			break;
		}
			
		case 1:
		{
			// 1
			[cell addSubview:_bgVoiceLabel];
			[cell addSubview:_bgVoiceSwitch];

			break;
		}
			
		case 2:
		{
			// 2
			[cell addSubview:_personVoiceLabel];
			[cell addSubview:_personVoiceSegment];
			break;
		}
			
		case 3:
		{
			// 3
			[cell addSubview:_speedVoiceLabel];
			[cell addSubview:_speedVoiceSlider];

			break;
		}
			
		case 4:
		{
			// 4
			[cell addSubview:_volumeVoiceLabel];
			[cell addSubview:_volumeVoiceSlider];

			break;
		}

		default:
			break;
	}
	
    return cell;
}

@end


