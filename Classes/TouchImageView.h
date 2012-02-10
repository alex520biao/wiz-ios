//
//  TouchImageView.h
//  Wiz
//
//  Created by dong zhao on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TouchImageView : UIImageView {
    id target;
    SEL process;
}
@property (nonatomic, retain) id target;
@property  SEL process;

@end
