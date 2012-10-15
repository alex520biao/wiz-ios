    //
//  UISynthesizerController.m
//  MSC20Demo
//
//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import "UISynthesizerController.h"

@interface UISynthesizerController(Private)

- (void)disableButton;

- (void)enableButton;

@end

@implementation UISynthesizerController

- (id)init
{
	if (self = [super init])
	{
		self.title = TITLE;

	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark 
#pragma mark 接口回调

//	Synthesis end callback, when you execute  cancel function this function will be called. 
//  合成回调函数，当你执行了cancel函数，整个会话结束时，会调用这个函数
- (void)onSynthesizerEnd:(IFlySynthesizerControl *)iFlySynthesizerControl theError:(SpeechError) error
{
    
	NSLog(@"finish.....");
	[self enableButton];

	// get the upload flow and download flow
    // 获取上传流量和下载流量   
	NSLog(@"upFlow:%d,downFlow:%d",[iFlySynthesizerControl getUpflow],[iFlySynthesizerControl getDownflow]);
}

// get the player buffer progress
// 获取播放器缓冲进度
- (void)onSynthesizerBufferProgress:(float)bufferProgress
{
    NSLog(@"the playing buffer :%f",bufferProgress);
}

// get the player progress
// 获取播放器的播放进度
- (void)onSynthesizerPlayProgress:(float)playProgress
{
    NSLog(@"the playing progress :%f",playProgress);
}

#pragma mark 
#pragma mark 内部调用

- (void)disableButton
{
	_synthesizerButton.enabled = NO;
	_setupButton.enabled = NO;
	_textView.editable = NO;
	self.navigationController.navigationItem.leftBarButtonItem.enabled  = NO;
}

- (void)enableButton
{
	_synthesizerButton.enabled = YES;
	_setupButton.enabled = YES;
	_textView.editable = YES;
	self.navigationController.navigationItem.leftBarButtonItem.enabled = YES;
}


- (void)onButtonSynthesizer
{
	[_iFlySynthesizerControl setText:_textView.text theParams:nil];
    
    // begin synthesize
    // 调用start方法，开始合成
	if([_iFlySynthesizerControl start])
	{
		[self disableButton];
	}
}


- (void)onButtonSetup
{
	[self.navigationController pushViewController:_synthesizerSetupController animated:YES];
}

- (void)viewDidLoad 
{
    // get initalization parameters    
    // 获得初始化参数，    
	NSString *initParam = [[NSString alloc] initWithFormat:
						   @"server_url=%@,appid=%@",ENGINE_URL,APPID];
	
	// init the SyntherSizerControl
    // 初始化语音合成控件  
	_iFlySynthesizerControl = [[IFlySynthesizerControl alloc] initWithOrigin:H_CONTROL_ORIGIN theInitParam:initParam];

    // configure the SyntherSizerControl,you can set the SampleRate,delegate, and so on
    // 配置语音合成控件，比如采样率，委托对象，发音人等等。
	_iFlySynthesizerControl.delegate = self;
	[self.view addSubview:_iFlySynthesizerControl];
    
    [initParam release];
	_synthesizerSetupController = [[UISynthesizerSetupController alloc] initWithSynthesizer:_iFlySynthesizerControl];
	[super viewDidLoad];	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_textView resignFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
// 自定义tableview的selection数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 0;
	if (indexPath.section == 0) 
	{
		height = 185;
	}
	else 
	{
		height = 110;
	}
	return height;
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
	
	if (indexPath.section == 0)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input.png"]];
		imageView.frame = H_BACK_TEXTVIEW_FRAME;
		[cell addSubview:imageView];
		[imageView release];
		
		_textView = [[self addTextViewWithFrame:H_TEXTVIEW_FRAME theText:TEXT_SHOW] retain];
		_textView.backgroundColor = [UIColor clearColor];
		[cell addSubview: _textView];
	}
	else
	{
        // configure the button

		_synthesizerButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        _synthesizerButton.frame = CGRectMake(20, 10, 280, 40);
		[_synthesizerButton setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];

        //  add the target for button ,when the button was clicked ,the onButtonSynthesizer function will be called
        //  为button添加onButtonSynthesizer响应函数，
		[_synthesizerButton addTarget:self action:@selector(onButtonSynthesizer) forControlEvents:UIControlEventTouchDown];
		
		[cell addSubview:_synthesizerButton];

        // configure the button		

		_setupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

		_setupButton.frame = CGRectMake(20, 60, 280, 40);
		[_setupButton setTitle:BUTTON_TITLE2 forState:UIControlStateNormal];
        
        //  add the target for button. when the button was clicked ,the onButtonSetup function will be called
        //  为button添加onButtonSetup响应函数
		[_setupButton addTarget:self action:@selector(onButtonSetup) forControlEvents:UIControlEventTouchDown];
		
		[cell addSubview:_setupButton];
	}
	
    return cell;
}

@end
