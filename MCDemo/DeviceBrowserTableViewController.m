//
//  DeviceBrowserTableViewController.m
//  MCDemo
//
//  Created by Abdullah Bakhach on 9/20/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "DeviceBrowserTableViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"

@interface DeviceBrowserTableViewController ()<MCNearbyServiceBrowserDelegate>

@property (nonatomic) MCNearbyServiceBrowser* mcBrowser;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *peers;
- (IBAction)backButtonClicked:(id)sender;
@end

@implementation DeviceBrowserTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Browse for Vibereels
    _mcBrowser = [[MCNearbyServiceBrowser alloc]
                  initWithPeer:[[MCPeerID alloc] initWithDisplayName:[[[_appDelegate mcManager] peerID] displayName]]
                  serviceType:@"chat-files"];
    _mcBrowser.delegate = self;
    [_mcBrowser startBrowsingForPeers];
    
    _peers = [@[] mutableCopy];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"peerCellIdentifier"
                                                                    forIndexPath:indexPath];
    [cell.textLabel setText:[_peers[indexPath.row] displayName]];
    return cell;
}

# pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // request to join peer
    [_mcBrowser invitePeer:_peers[indexPath.row] toSession:[[_appDelegate mcManager] session] withContext:nil timeout:30];
    
}

#pragma mark - MCNearbyServiceBrowserDelegate
- (void)              browser:(MCNearbyServiceBrowser *)browser
  didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Failed to browse for peers: %@", [error localizedDescription]);
}

- (void)              browser:(MCNearbyServiceBrowser *)browser
                    foundPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(NSDictionary *)info
{
    if ([[peerID displayName] isEqualToString:[UIDevice currentDevice].name]) {
        return;
    }
    
    NSLog(@"we found peer %@", [peerID displayName]);
    
    [_peers addObject:peerID];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_peers count]-1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)              browser:(MCNearbyServiceBrowser *)browser
                     lostPeer:(MCPeerID *)peerID
{
    NSLog(@"we lost peer");
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
