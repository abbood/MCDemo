//
//  SecondViewController.h
//  MCDemo
//
//  Created by Gabriel Theodoropoulos on 1/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblFiles;

@end
