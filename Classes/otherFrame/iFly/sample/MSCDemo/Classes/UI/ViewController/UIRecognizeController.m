    //
//  UIRecognizeController.m
//  MSC20Demo
//
//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import "UIRecognizeController.h"

@interface UIRecognizeController(Private)

- (void)disableButton;

- (void)enableButton;

@end

@implementation UIRecognizeController

- (id)init
{
	if (self = [super init])
	{
		self.title = TITLE;
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark 
#pragma mark 接口回调

//	recognition end callback
//  识别结束回调函数，当整个会话过程结束时候会调用这个函数
- (void)onRecognizeEnd:(IFlyRecognizeControl *)iFlyRecognizeControl theError:(SpeechError) error
{
	NSLog(@"识别结束回调finish.....");
	[self enableButton];
	
	NSLog(@"getUpflow:%d,getDownflow:%d",[iFlyRecognizeControl getUpflow],[iFlyRecognizeControl getDownflow]);
	
}

//  set the textView
//  设置textview中的文字，既返回的识别结果
- (void)onUpdateTextView:(NSString *)sentence
{
	
	NSString *str = [[NSString alloc] initWithFormat:@"%@%@", _textView.text, sentence];
	_textView.text = str;
	
	NSLog(@"str");
}

- (void)onRecognizeResult:(NSArray *)array
{
    //  execute the onUpdateTextView function in main thread
    //  在主线程中执行onUpdateTextView方法 
	[self performSelectorOnMainThread:@selector(onUpdateTextView:) withObject:
	 [[array objectAtIndex:0] objectForKey:@"NAME"] waitUntilDone:YES];
}

//  recognition result callback
//  识别结果回调函数
- (void)onResult:(IFlyRecognizeControl *)iFlyRecognizeControl theResult:(NSArray *)resultArray
{
	[self onRecognizeResult:resultArray];	
	
}
#pragma mark 
#pragma mark 内部调用

// to disableButton,when the recognizer view display,the function will be called
// 当显示语音识别的view时，使其他的按钮不可用
- (void)disableButton
{
	_recognizeButton.enabled = NO;
	_setupButton.enabled = NO;
	_textView.editable = NO;
	self.navigationController.navigationItem.leftBarButtonItem.enabled = NO;
}

// to enable button,when you start recognizer,this function will be called
// 当语音识别view消失的时候，使其它按钮可用
- (void)enableButton
{
	_recognizeButton.enabled = YES;
	_setupButton.enabled = YES;
	_textView.editable = YES;
	self.navigationController.navigationItem.leftBarButtonItem.enabled  = YES;
}

// 开始语音识别，
- (void)onButtonRecognize
{
    // begin to recognize 
	if([_iFlyRecognizeControl start])
	{
		[self disableButton];
	}
}

// to setup the recognizer
// 打开语音识别的设置界面
- (void)onButtonSetup
{
	[self.navigationController pushViewController:_recoginzeSetupController animated:YES];
}

- (void)viewDidLoad 
{
	NSString *initParam = [[NSString alloc] initWithFormat:
						   @"server_url=%@,appid=%@",ENGINE_URL,APPID];

	// init the RecognizeControl
    // 初始化语音识别控件   
	_iFlyRecognizeControl = [[IFlyRecognizeControl alloc] initWithOrigin:H_CONTROL_ORIGIN theInitParam:initParam];
	
    [self.view addSubview:_iFlyRecognizeControl];
    
    // Configure the RecognizeControl
    // 设置语音识别控件的参数,具体参数可参看开发文档
	[_iFlyRecognizeControl setEngine:@"sms" theEngineParam:nil theGrammarID:nil];
	[_iFlyRecognizeControl setSampleRate:16000];
	_iFlyRecognizeControl.delegate = self;
	
    [initParam release];
	
	_recoginzeSetupController = [[UIRecognizeSetupController alloc] initWithRecognize:_iFlyRecognizeControl];
	[super viewDidLoad];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_textView resignFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Customize the size of tableview
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
	// 自定义cell
	if (indexPath.section == 0)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input.png"]];
		imageView.frame = H_BACK_TEXTVIEW_FRAME;
		[cell addSubview:imageView];
		[imageView release];
		
		_textView = [[self addTextViewWithFrame:H_TEXTVIEW_FRAME theText:nil] retain];
		_textView.backgroundColor = [UIColor clearColor];
		[cell addSubview: _textView];
	}
	else
	{
        // Configure the button
		_recognizeButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        _recognizeButton.frame = CGRectMake(20, 10, 280, 40);
		[_recognizeButton setTitle:BUTTON_TITLE1 forState:UIControlStateNormal];
        
        // add the onButtonRecognize funciton for the button
        // 为按钮添加onButtonRecognize响应函数       
		[_recognizeButton addTarget:self action:@selector(onButtonRecognize) forControlEvents:UIControlEventTouchDown];

        // add the button to the cell		
        // 将button加入cell中        
		[cell addSubview:_recognizeButton];
		
        // Configure the button
        // 自定义button       
		_setupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_setupButton.frame = CGRectMake(20, 60, 280, 40);
		[_setupButton setTitle:BUTTON_TITLE2 forState:UIControlStateNormal];
        
        // add the onButtonSetup funciton for the button
        // 为按钮添加onButtonSetup响应函数        
		[_setupButton addTarget:self action:@selector(onButtonSetup) forControlEvents:UIControlEventTouchDown];

        // add the button to the cell		
		[cell addSubview:_setupButton];
	}

    return cell;
}


@end
