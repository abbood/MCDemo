//
//  MCManager.h
//  MCDemo
//
//  Created by Gabriel Theodoropoulos on 1/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
