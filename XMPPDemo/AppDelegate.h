//
//  AppDelegate.h
//  XMPPDemo
//
//  Created by KindleBit on 15/04/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

#import "XMPP.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPRosterDelegate>
{
  
}

@property (strong, nonatomic) UIWindow *window;


@end

