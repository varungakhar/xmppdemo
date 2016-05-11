//
//  FriendsViewController.m
//  XMPPDemo
//
//  Created by KindleBit on 10/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "FriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
    
    
// Do any additional setup after loading the view from its nib.
}
-(IBAction)adduser:(id)sender
{
    
    [[XMPP sharedxmpp]adduser];
    
    
}
-(IBAction)registeruser:(id)sender
{
        NSDictionary *dict=@{@"action":@"fetchuser"};
        [[XMPP sharedxmpp]getalluser:dict result:^(NSString *result, NSDictionary *error, id data)
         {
    
        }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
