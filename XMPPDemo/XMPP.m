//
//  XMPP.m
//  XMPPDemo
//
//  Created by KindleBit on 10/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "XMPP.h"

@implementation XMPP

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

static XMPP *sharedxmpp=nil;


+(XMPP*)sharedxmpp
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedxmpp=[[XMPP alloc]init];
    });
    
    
    return sharedxmpp;
}


- (void)setupStream
{
    
    
    xmppStream = [[XMPPStream alloc] init];
    
    
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppStream setHostName:@"localhost"];
    [xmppStream setHostPort:5222];
    
    
    NSError *error = nil;
    
    
    
    NSString *JID=[NSString stringWithFormat:@"%@@varun.local",@"annoymous"];
    
    
    password=@"";
    
    
    [xmppStream setMyJID:[XMPPJID jidWithString:JID]];
    
    
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

    customCertEvaluation = YES;
}
-(void)login:(NSString *)username password:(NSString*)userpassword result:(response)result
{
    if (![xmppStream isDisconnected])
    {
        
    }
    NSString *myJID=[NSString stringWithFormat:@"%@@varun.local",username];
    NSString *myPassword =userpassword;
    password=userpassword;
    
    if (myJID == nil || myPassword == nil)
    {
      
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    
    
    NSError *error = nil;
    
   
    [xmppStream disconnect];
    
    
        if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                                message:@"See console for error details."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
  
    

    send=result;
    
}
-(void)registeruser:(NSDictionary *)dict result:(response)result
{
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:[dict valueForKey:@"username"]]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:[dict valueForKey:@"password"]]];
    [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:[dict valueForKey:@"email"]]];
    [elements addObject:[NSXMLElement elementWithName:@"phone" stringValue:[dict valueForKey:@"phone"]]];

    [xmppStream registerWithElements:elements error:nil];
    
    send=result;
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    if (send)
    {
          send(@"yes",@{});
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{

DDXMLElement *errorXML = [error elementForName:@"error"];
NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    if (send)
    {
         send(@"no",@{@"errorcode":errorCode,@"error":regError});
    }
  
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
   
    
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    if (customCertEvaluation)
    {
        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    }
}


- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{

    NSError *error = nil;
    
  
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        
    }
//    [xmppStream oldSchoolSecureConnectWithTimeout:1 error:&error];
    
}
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
    if (send)
    {
    [self goOnline];
       send(@"yes",@{});
    }
}
- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}
- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    
    if (!errorCode)
    {
        errorCode=@"";
    }
    if (!regError)
    {
        regError=@"";
    }
    if (send)
    {
        send(@"no",@{@"errorcode":errorCode,@"error":regError});
    }

}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    

    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                                message:body
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}
- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername])
    {
        
        if ([presenceType isEqualToString:@"available"])
        {
            NSLog(@"av..%@",presenceFromUser);
            NSLog(@"av..%@",presenceType);
            NSLog(@"av..%@",myUsername);
        }
        else if ([presenceType isEqualToString:@"unavailable"])
        {
            NSLog(@"nav..%@",presenceFromUser);
            NSLog(@"nav..%@",presenceType);
            NSLog(@"nav..%@",myUsername);
        }
        
    }
    
    
    NSLog(@"presence....%@",[presence fromStr]);
    
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (error)
    {
        //  DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}

@end
