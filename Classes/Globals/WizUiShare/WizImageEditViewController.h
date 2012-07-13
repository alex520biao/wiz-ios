//
//  WizImageEditViewController.h
//  Wiz
//
//  Created by wiz on 12-7-12.
//
//

#import <UIKit/UIKit.h>

@protocol WizImageEditDelegate <NSObject>
- (void) editorImageDone;
@end

@interface WizImageEditViewController : UIViewController
{
    NSString* sourcePath;
    id<WizImageEditDelegate> editDelegate;
}
@property (nonatomic, assign) id<WizImageEditDelegate> editDelegate;
@property (nonatomic, retain) NSString* sourcePath;
@end
