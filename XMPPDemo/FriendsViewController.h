//
//  FriendsViewController.h
//  XMPPDemo
//
//  Created by KindleBit on 10/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
@interface FriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UINavigationBar *navbar;
    NSMutableArray *array;
    IBOutlet UITableView *table;
    
}
@end
