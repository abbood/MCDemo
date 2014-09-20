//
//  SecondViewController.m
//  MCDemo
//
//  Created by Gabriel Theodoropoulos on 1/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"

@interface SecondViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSMutableArray *arrFiles;
@property (nonatomic, strong) NSString *selectedFile;
@property (nonatomic) NSInteger selectedRow;


-(void)copySampleFilesToDocDirIfNeeded;
-(NSArray *)getAllDocDirFiles;
-(void)didStartReceivingResourceWithNotification:(NSNotification *)notification;
-(void)updateReceivingProgressWithNotification:(NSNotification *)notification;
-(void)didFinishReceivingResourceWithNotification:(NSNotification *)notification;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self copySampleFilesToDocDirIfNeeded];
    _arrFiles = [[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];
    
    [_tblFiles setDelegate:self];
    [_tblFiles setDataSource:self];
    
    [_tblFiles reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didStartReceivingResourceWithNotification:)
                                                 name:@"MCDidStartReceivingResourceNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReceivingProgressWithNotification:)
                                                 name:@"MCReceivingProgressNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishReceivingResourceWithNotification:)
                                                 name:@"didFinishReceivingResourceNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private method implementation

-(void)copySampleFilesToDocDirIfNeeded{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    
    NSString *file1Path = [_documentsDirectory stringByAppendingPathComponent:@"sample_file1.txt"];
    NSString *file2Path = [_documentsDirectory stringByAppendingPathComponent:@"sample_file2.txt"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    
    if (![fileManager fileExistsAtPath:file1Path] || ![fileManager fileExistsAtPath:file2Path]) {
        [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sample_file1" ofType:@"txt"]
                             toPath:file1Path
                              error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
        
        [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sample_file2" ofType:@"txt"]
                             toPath:file2Path
                              error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
    }
}


-(NSArray *)getAllDocDirFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:_documentsDirectory error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    
    return allFiles;
}


-(void)didStartReceivingResourceWithNotification:(NSNotification *)notification{
    [_arrFiles addObject:[notification userInfo]];
    [_tblFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


-(void)updateReceivingProgressWithNotification:(NSNotification *)notification{
    NSProgress *progress = [[notification userInfo] objectForKey:@"progress"];
    
    NSDictionary *dict = [_arrFiles objectAtIndex:(_arrFiles.count - 1)];
    NSDictionary *updatedDict = @{@"resourceName"  :   [dict objectForKey:@"resourceName"],
                                  @"peerID"        :   [dict objectForKey:@"peerID"],
                                  @"progress"      :   progress
                                  };
    
    
    
    [_arrFiles replaceObjectAtIndex:_arrFiles.count - 1
                         withObject:updatedDict];
    
    [_tblFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


-(void)didFinishReceivingResourceWithNotification:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    
    NSURL *localURL = [dict objectForKey:@"localURL"];
    NSString *resourceName = [dict objectForKey:@"resourceName"];
    
    NSString *destinationPath = [_documentsDirectory stringByAppendingPathComponent:resourceName];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager copyItemAtURL:localURL toURL:destinationURL error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_arrFiles removeAllObjects];
    _arrFiles = nil;
    _arrFiles = [[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];
    
    [_tblFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrFiles count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    if ([[_arrFiles objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        cell.textLabel.text = [_arrFiles objectAtIndex:indexPath.row];
        
        [[cell textLabel] setFont:[UIFont systemFontOfSize:14.0]];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"newFileCellIdentifier"];
        
        NSDictionary *dict = [_arrFiles objectAtIndex:indexPath.row];
        NSString *receivedFilename = [dict objectForKey:@"resourceName"];
        NSString *peerDisplayName = [[dict objectForKey:@"peerID"] displayName];
        NSProgress *progress = [dict objectForKey:@"progress"];
        
        [(UILabel *)[cell viewWithTag:100] setText:receivedFilename];
        [(UILabel *)[cell viewWithTag:200] setText:[NSString stringWithFormat:@"from %@", peerDisplayName]];
        [(UIProgressView *)[cell viewWithTag:300] setProgress:progress.fractionCompleted];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[_arrFiles objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        return 60.0;
    }
    else{
        return 80.0;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selectedFile = [_arrFiles objectAtIndex:indexPath.row];
    UIActionSheet *confirmSending = [[UIActionSheet alloc] initWithTitle:selectedFile
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
    
    for (int i=0; i<[[_appDelegate.mcManager.session connectedPeers] count]; i++) {
        [confirmSending addButtonWithTitle:[[[_appDelegate.mcManager.session connectedPeers] objectAtIndex:i] displayName]];
    }
    
    [confirmSending setCancelButtonIndex:[confirmSending addButtonWithTitle:@"Cancel"]];
    
    [confirmSending showInView:self.view];
    
    _selectedFile = [_arrFiles objectAtIndex:indexPath.row];
    _selectedRow = indexPath.row;
}


#pragma mark - UIActionSheet Delegate method implementation

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != [[_appDelegate.mcManager.session connectedPeers] count]) {
        NSString *filePath = [_documentsDirectory stringByAppendingPathComponent:_selectedFile];
        NSString *modifiedName = [NSString stringWithFormat:@"%@_%@", _appDelegate.mcManager.peerID.displayName, _selectedFile];
        NSURL *resourceURL = [NSURL fileURLWithPath:filePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = [_appDelegate.mcManager.session sendResourceAtURL:resourceURL
                                                                            withName:modifiedName
                                                                              toPeer:[[_appDelegate.mcManager.session connectedPeers] objectAtIndex:buttonIndex]
                                                               withCompletionHandler:^(NSError *error) {
                                                                   if (error) {
                                                                       NSLog(@"Error: %@", [error localizedDescription]);
                                                                   }
                                                                   
                                                                   else{
                                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MCDemo"
                                                                                                                       message:@"File was successfully sent."
                                                                                                                      delegate:self
                                                                                                             cancelButtonTitle:nil
                                                                                                             otherButtonTitles:@"Great!", nil];
                                                                       
                                                                       [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                                                       
                                                                       [_arrFiles replaceObjectAtIndex:_selectedRow withObject:_selectedFile];
                                                                       [_tblFiles performSelectorOnMainThread:@selector(reloadData)
                                                                                                   withObject:nil
                                                                                                waitUntilDone:NO];
                                                                   }
                                                               }];
            
            //NSLog(@"*** %f", progress.fractionCompleted);
            
            [progress addObserver:self
                       forKeyPath:@"fractionCompleted"
                          options:NSKeyValueObservingOptionNew
                          context:nil];
        });
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSString *sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%",
                                _selectedFile,
                                [(NSProgress *)object fractionCompleted] * 100
                                ];
    
    [_arrFiles replaceObjectAtIndex:_selectedRow withObject:sendingMessage];
    
    [_tblFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
