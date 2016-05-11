//
//  ViewController.m
//  XMPPDemo
//
//  Created by KindleBit on 15/04/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
-(IBAction)login:(id)sender
{
    
    NSDictionary *dict=@{
                         @"username":usertextfield.text,@"password":passwordtext.text,@"action":@"login"
                         
                         };
    
    
    [[XMPP sharedxmpp]login:dict result:^(NSString *result ,NSDictionary *dict , id data)
    {
        if ([result isEqualToString:@"yes"])
        {
    FriendsViewController *friends=[[FriendsViewController alloc]init];
    [self.navigationController pushViewController:friends animated:YES];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                                message:@"Password Wrong"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
        }
        
        
        
    }];
}
-(IBAction)signup:(id)sender
{
    SignUpViewController *sign=[[SignUpViewController alloc]init];
    [self.navigationController pushViewController:sign animated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
