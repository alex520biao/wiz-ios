//
//  AttachmentView.h
//  Wiz
//
//  Created by dong zhao on 11-11-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ImageToucheDelegate
-(void)imageTouch:(NSSet*) touches withEvent:(UIEvent*) event whichView:(id)imageView;

@end

@interface AttachmentView : UIImageView {
    UIImage* image;   
    NSString* attachGUID;
    NSString* accountID;
    id<ImageToucheDelegate> delegate;
    BOOL delegatrue;
    NSString* name;
}

@property (nonatomic, retain) id<ImageToucheDelegate> delegate;
@property (nonatomic, retain) NSString* attachGUID;
@property (nonatomic, retain) NSString* accountID;
@property (nonatomic, retain) NSString*  name;
@property (assign) BOOL delegatrue;

@end
