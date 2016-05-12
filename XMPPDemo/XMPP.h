//
//  XMPP.h
//  XMPPDemo
//
//  Created by KindleBit on 10/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import <CoreData/CoreData.h>
#import "DDLog.h"
#import "XMPPRoomMemoryStorage.h"
typedef void(^response)(NSString *result,NSDictionary  *error,id data);
typedef void(^sendresponse)(NSString *result,NSDictionary *error,id data);
@interface XMPP : NSObject<XMPPRosterDelegate>
{
    NSString *password;
    BOOL customCertEvaluation;
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    sendresponse send;
    NSDictionary *savedict;
    
    
}
+(XMPP*)sharedxmpp;
- (void)setupStream;
-(void)adduser;
-(void)login:(NSDictionary *)userdetails result:(response)result;
-(void)registeruser:(NSDictionary *)dict result:(response)result;
-(void)getalluser:(NSDictionary*)dict result:(response)result;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@end
