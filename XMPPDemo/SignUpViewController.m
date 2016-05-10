//
//  SignUpViewController.m
//  XMPPDemo
//
//  Created by KindleBit on 10/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(IBAction)signup:(id)sender
{
    NSDictionary *dict=@{@"username":usertextfield.text,@"password":passwordtext.text,@"email":emailtext.text,@"phone":phonetext.text};
    
    [[XMPP sharedxmpp]registeruser:dict result:^(NSString *result, NSDictionary *error)
    {
        if ([result isEqualToString:@"yes"])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *regError=[error objectForKey:@"error"];
            NSString *errorCode=[error objectForKey:@"errorcode"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            if([errorCode isEqualToString:@"409"])
            {
                [alert setMessage:@"Username Already Exists!"];
            }
            
            [alert show];
        }
      
    
    
    }];
    
    
    
 
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}



@end
