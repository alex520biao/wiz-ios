//
//  WizTestUnit.h
//  Wiz
//
//  Created by wiz on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef Wiz_WizTestUnit_h
#define Wiz_WizTestUnit_h
#define _DEBUG 
#ifdef _DEBUG
#import "TestFlight.h"
#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define teamToken @"5bfb46cb74291758452c20108e140b4e_NjY0MzAyMDEyLTAyLTI5IDA0OjIwOjI3LjkzNDUxOQ"
#endif
#endif
