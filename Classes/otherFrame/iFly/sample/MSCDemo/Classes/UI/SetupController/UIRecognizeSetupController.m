//
//  UIRecognizeSetupController.m
//  MSC20Demo
//
//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import "UIRecognizeSetupController.h"

@interface UIRecognizeSetupController(Private)


@end

@implementation UIRecognizeSetupController

- (id)initWithRecognize:(IFlyRecognizeControl *)iFlyRecognizeControl
{
	if (self = [super initWithStyle:UITableViewStyleGrouped])
	{
		self.title = TITLE;
		_iFlyRecognizeControl = [iFlyRecognizeControl retain];
		
	}
	return self;
}

- (void)dealloc 
{
    [super dealloc];
}

#pragma mark 
#pragma mark 内部调用

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // 配置语音识别的设置界面	
	// 转写类型
	_recognizeTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 130, 40)];
	_recognizeTypeLabel.text = @"转写类型:";
	_recognizeTypeLabel.backgroundColor = [UIColor clearColor];
	_recognizeTypeLabel.font = [UIFont systemFontOfSize:20.0f];
	_recognizeTypeLabel.textColor = [UIColor blackColor];
	_recognizeTypeLabel.textAlignment = UITextAlignmentLeft;
	
	
	NSArray *array = [[NSArray alloc] initWithObjects:@"转写",@"地图搜索",nil];
	_recognizeTypeSegment = [[UISegmentedControl alloc] initWithItems:array];
	_recognizeTypeSegment.frame = CGRectMake(120, 5, 160, 40);
	
	[_recognizeTypeSegment addTarget:self action:@selector(recognizeTypeChanged) forControlEvents:UIControlEventValueChanged];
	_recognizeTypeSegment.selectedSegmentIndex = 0;
	[array release];
	
	_areaPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	_areaPickerView.delegate = self;
	_areaPickerView.dataSource = self;
	
	_areaPickerView.frame = CGRectMake(60, 10, 200, 50);//[self pickerFrameWithSize:pickerSize];
	
	_areaPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	_areaPickerView.hidden = YES;
	
	_pickerViewArray = [[NSArray alloc] initWithObjects:@"合肥市",@"北京市",@"中国",@"浙江省杭州市",nil];
	_selectRow = 0;
	[_areaPickerView selectRow:_selectRow inComponent:0 animated:NO]; 
}

// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 42.0 - size.height,
								   size.width,
								   size.height);
	return pickerRect;
}

- (void)recognizeTypeChanged
{
	if(_recognizeTypeSegment.selectedSegmentIndex == 0)
	{
		[_iFlyRecognizeControl setEngine:@"sms" theEngineParam:nil theGrammarID:nil];
		_areaPickerView.hidden = YES;
	}
	else 
	{
		[_iFlyRecognizeControl setEngine:@"poi" theEngineParam:
		 [NSString stringWithFormat:@"area=%@",[_pickerViewArray objectAtIndex:_selectRow]]
							theGrammarID:nil];
		_areaPickerView.hidden = NO;
	}
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	_selectRow = row;
	
	[_iFlyRecognizeControl setEngine:@"poi" theEngineParam:
	 [NSString stringWithFormat:@"area=%@",[_pickerViewArray objectAtIndex:_selectRow]]
						theGrammarID:nil];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

// to realize the protocol 
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	
	if (component == 0)
	{
		returnStr = [_pickerViewArray objectAtIndex:row];
	}
	else
	{
		returnStr = [[NSNumber numberWithInt:row] stringValue];
	}
	
	
	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 170.0;
	
	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_pickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 0;
	if (indexPath.section == 0) 
	{
		height = 50;
	}
	else 
	{
		height = 180;
	}
	return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* sectionTitle = nil;
	switch (section) 
	{
		case 0:
			sectionTitle = SECTION_TITLE1;
			break;
		case 1: 
			sectionTitle = SECTION_TITLE2;//@"类型";
			break;
	}
	return sectionTitle;
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
		// 转写类型
		[cell addSubview:_recognizeTypeLabel];
		[cell addSubview:_recognizeTypeSegment];
		
	}
	else
	{
		[cell addSubview:_areaPickerView];
	}
	
    return cell;
}


@end
