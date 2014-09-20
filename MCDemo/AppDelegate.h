//
//  AppDelegate.h
//  MCDemo
//
//  Created by Gabriel Theodoropoulos on 1/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MCManager *mcManager;

@end
