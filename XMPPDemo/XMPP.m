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
    savedict =@{@"action":@""};
    
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





#pragma mark GetAllRegisteredUser

-(void)getalluser:(NSDictionary*)dict result:(response)result
{
    
    NSError *error ;
    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='http://jabber.org/protocol/disco#items' node='all users'/>"
                                                            error:&error];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"
                                 to:[XMPPJID jidWithString:@"localhost"]
                          elementID:[xmppStream generateUUID] child:query];
    [xmppStream sendElement:iq];
    
//    NSError *error ;
//    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
//    
//    NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
//    [iqStanza addAttributeWithName: @"type" stringValue: @"get"];
//    [iqStanza addChild: queryElement];
//    
//    [xmppStream sendElement: iqStanza];
    
    
//    NSString *userBare1  = [[xmppStream myJID] bare];
//    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
//    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
//    
//    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
//    [x addAttributeWithName:@"type" stringValue:@"submit"];
//    
//    NSXMLElement *formType = [NSXMLElement elementWithName:@"field"];
//    [formType addAttributeWithName:@"type" stringValue:@"hidden"];
//    [formType addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
//    [formType addChild:[NSXMLElement elementWithName:@"value" stringValue:@"jabber:iq:search" ]];
//    
//    NSXMLElement *userName = [NSXMLElement elementWithName:@"field"];
//    [userName addAttributeWithName:@"var" stringValue:@"Username"];
//    [userName addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1" ]];
//    
//    NSXMLElement *name = [NSXMLElement elementWithName:@"field"];
//    [name addAttributeWithName:@"var" stringValue:@"Name"];
//    [name addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//    
//    NSXMLElement *email = [NSXMLElement elementWithName:@"field"];
//    [email addAttributeWithName:@"var" stringValue:@"Email"];
//    [email addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
//    
//    //Here in the place of SearchString we have to provide registered user name or emailid or username(if it matches in Server it provide registered user details otherwise Server provides response as empty)
//    NSXMLElement *search = [NSXMLElement elementWithName:@"field"];
//    [search addAttributeWithName:@"var" stringValue:@"search"];
//    [search addChild:[NSXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"%@", @"varun.local"]]];
//    
//    [x addChild:formType];
//    [x addChild:userName];
//    [x addChild:name];
//    [x addChild:email];
//    [x addChild:search];
//    [query addChild:x];
//    
//    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
//    [iq addAttributeWithName:@"type" stringValue:@"set"];
//    [iq addAttributeWithName:@"id" stringValue:@"searchByUserName"];
//    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",@"varun.local"]];
//    [iq addAttributeWithName:@"from" stringValue:userBare1];
//    [iq addChild:query];
//    [ xmppStream sendElement:iq];
//
    
    
    
    savedict =dict;
    send=result;
    
}
#pragma mark Login

-(void)login:(NSDictionary *)userdetails result:(response)result
{
    if (![xmppStream isDisconnected])
    {
        
    }
    NSString *myJID=[NSString stringWithFormat:@"%@@varun.local",[userdetails valueForKey:@"username"]];
    NSString *myPassword =[userdetails valueForKey:@"password"];
    password=[userdetails valueForKey:@"password"];
    
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
    savedict=userdetails;
    
    send=result;
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

#pragma mark Register


-(void)registeruser:(NSDictionary *)dict result:(response)result
{
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:[dict valueForKey:@"username"]]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:[dict valueForKey:@"password"]]];
    [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:[dict valueForKey:@"email"]]];
    [elements addObject:[NSXMLElement elementWithName:@"phone" stringValue:[dict valueForKey:@"phone"]]];
    
    [xmppStream registerWithElements:elements error:nil];
    savedict=dict;
    send=result;
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    if ([[savedict objectForKey:@"action"]isEqualToString:@"signup"])
    {
        send(@"yes",@{},nil);
    }
    
    
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    if ([[savedict objectForKey:@"action"]isEqualToString:@"signup"])
    {
        send(@"no",@{@"errorcode":errorCode,@"error":regError},nil);
    }
    
}

#pragma mark ConnectStream

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
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
    if ([[savedict objectForKey:@"action"]isEqualToString:@"login"])
    {
       [self goOnline];
       send(@"yes",@{},nil);
    }
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
    if ([[savedict objectForKey:@"action"]isEqualToString:@"login"])
    {
        send(@"no",@{@"errorcode":errorCode,@"error":regError},nil);
    }

}

#pragma mark Receive IQ

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    if ([[savedict objectForKey:@"action"]isEqualToString:@"fetchuser"])
    {
NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"http://jabber.org/protocol/disco#items"];
        
        if (queryElement)
        {
            NSArray *itemElements = [queryElement elementsForName: @"item"];
            NSMutableArray *mArray = [[NSMutableArray alloc] init];
            for (int i=0; i<[itemElements count]; i++)
            {
                NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
                [mArray addObject:jid];
            }
            
            
            if (mArray.count<=0)
            {
            send(@"no",@{@"errorcode":@"5551",@"error":@"Not Found"},nil);
            }
            else
            {
                send(@"yes",@{},mArray);
            }
        
           
            
    }
    
    
  
    }
    
      return NO;
}

#pragma mark ReceiveMessage

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

#pragma mark Presence

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

#pragma mark Error


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


#pragma mark XMPPRosterDelegate

-(void)adduser
{
    XMPPJID *newBuddy = [XMPPJID jidWithString:@"atul@varun.local"];
    [xmppRoster addUser:newBuddy withNickname:nil];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage
                                           userForJID:[presence from]
                                           xmppStream:self.xmppStream
                                           managedObjectContext:[self managedObjectContext_roster]];
    [self.xmppRoster
                                acceptPresenceSubscriptionRequestFrom:[presence from]
                                andAddToRoster:YES];
}


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
