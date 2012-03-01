//
//  CloudReview.m
//  Wiz
//
//  Created by wiz on 12-2-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CloudReview.h"

@implementation CloudReview  
static CloudReview* _sharedReview = nil;  
+(CloudReview*)sharedReview  
{  
    @synchronized([CloudReview class])  
    {  
        if (!_sharedReview)  
            [[self alloc] init];  
        
        return _sharedReview;  
    }  
    
    return nil;  
}  
+(id)alloc  
{  
    @synchronized([CloudReview class])  
    {  
        NSAssert(_sharedReview == nil, @"Attempted to allocate a second instance of a singleton.");  
        _sharedReview = [super alloc];  
        return _sharedReview;  
    }  
    
    return nil;  
}  
-(void)reviewFor:(int)appleID  
{  
    m_appleID = appleID;  
    BOOL neverRate = NO;
    if(neverRate != YES) {  
        //Show alert here  
        UIAlertView *alert;  
       
        alert = [[UIAlertView alloc] initWithTitle:WizStrRateWizNote 
                                           message:NSLocalizedString(@"Please rate WizNote",nil)  
                                          delegate: self  
                                 cancelButtonTitle:WizStrCancel  
                                 otherButtonTitles: NSLocalizedString(@"Rate now",nil),  nil];  
        [alert show];  
        [alert release];  
    }  
}  
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  
{  
    if (buttonIndex == 1)  
    {  
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverRate"];  
        NSString *str = [NSString stringWithFormat:  
                         @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",  
                         m_appleID ];   
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];  
    }  
}  
@end   