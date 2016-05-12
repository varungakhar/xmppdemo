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
    
    //    NSDictionary *dict=@{@"action":@"fetchuser"};
    //    [[XMPP sharedxmpp]getalluser:dict result:^(NSString *result, NSDictionary *error, id data)
    //     {
    //
    //     }];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"FetchUser" style:UIBarButtonItemStyleDone target:self action:@selector(registeruser:)];
    array=[[NSMutableArray alloc]init];
}
-(IBAction)registeruser:(id)sender
{
        NSDictionary *dict=@{@"action":@"fetchuser"};
        [[XMPP sharedxmpp]getalluser:dict result:^(NSString *result, NSDictionary *error, id data)
         {
    
         }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *string=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:string];
    if (!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
    }
    cell.textLabel.text=[array objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
