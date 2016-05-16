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
    
    turnSockets=[[NSMutableArray alloc]init];
    
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
    
    _fileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [_fileTransfer activate:xmppStream];
//    _fileTransfer.disableIBB = NO;
//    _fileTransfer.disableSOCKS5 = NO;
    [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    _xmppIncomingFileTransfer = [XMPPIncomingFileTransfer new];
    [_xmppIncomingFileTransfer activate:xmppStream];
//    _xmppIncomingFileTransfer.disableIBB = NO;
//    _xmppIncomingFileTransfer.disableSOCKS5 = NO;
    [_xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
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
    
    
    
    NSString *JID=[NSString stringWithFormat:@"%@@varun.local",@"admin"];
    
    
    password=@"admin";
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

#pragma mark CreateRoom

-(void)createroom
{
    
XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc] init];
    
    XMPPJID *roomJID = [XMPPJID jidWithString:@"register@conference.varun.local"];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self
            delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:@"admin"
                            history:nil
                           password:nil];
}
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    [sender fetchConfigurationForm];
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    [sender configureRoomUsingOptions:newConfig];
}
#pragma mark GetAllRegisteredUser

-(void)getalluser:(NSDictionary*)dict result:(response)result
{
    
//    NSError *error ;
//    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='http://jabber.org/protocol/disco#items'/>"
//                                                            error:&error];
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"
//                                 to:[XMPPJID jidWithString:@"varun.local"]
//                          elementID:[xmppStream generateUUID] child:query];
//    [xmppStream sendElement:iq];
    

    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns:@"jabber:iq:roster"];
    
    NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
    [iqStanza addAttributeWithName: @"type" stringValue: @"get"];
    [iqStanza addChild: queryElement];
    
    [xmppStream sendElement: iqStanza];
    

    savedict =dict;
    send=result;
    
}


- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
{
    
    NSLog(@"TURN Connection succeeded!");
    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
    
    UIImage *image= [UIImage imageNamed:@"front.jpg"];
    
    
    NSData *dataF = UIImagePNGRepresentation(image);
    
    [socket writeData:dataF withTimeout:200 tag:2];
    
    
    [turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender
{
    
    NSLog(@"TURN Connection failed!");
    [turnSockets removeObject:sender];
    
}

- (void)readRecievedData:(NSData*)data withTurnSocket:(TURNSocket *)receiver
{
    
    NSLog(@"%@",data);
    
//    [fileTransferData appendData:data];
//    float progress = (float)[fileTransferData length] / (float)[data length];
//    
//    NSLog(@"Progresaa value is: %f",progress);
}

#pragma mark SendMessage

-(void)sendmessage:(NSDictionary *)userdict result:(response)result
{
    
    NSLog(@"Message sending fron Gmail");
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:[userdict objectForKey:@"message"]];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[userdict objectForKey:@"user"]];
    [message addChild:body];
    NSLog(@"message1%@",message);
    
    [xmppStream sendElement:message];
    
    
    
    
    savedict=userdict;
    send=result;
}

-(void)sendphoto:(NSDictionary *)userdict result:(response)result
{
    UIImage *image= [UIImage imageNamed:@"front.jpg"];
    
    
    NSData *dataF = UIImagePNGRepresentation(image);
//    NSString *imgStr=[dataF base64EncodedStringWithOptions:kNilOptions];
//    
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:[userdict objectForKey:@"message"]];
//    
//    NSXMLElement *imgAttachement = [NSXMLElement elementWithName:@"attachment"];
//    [imgAttachement setStringValue:imgStr];
//    
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    [message addAttributeWithName:@"to" stringValue:[userdict objectForKey:@"user"]];
//    [message addChild:body];
//    [message addChild:imgAttachement];
//    
//    [self.xmppStream sendElement:message];
    
    
    NSError *err;
    
    NSString *res=[XMPPJID jidWithString:[userdict valueForKey:@"user"]];
    
    NSString *string=resource;
    

//    if (![_fileTransfer sendData:dataF
//                           named:@"ff"
//                     toRecipient:[XMPPJID jidWithString:string]
//          
//                     description:@"Baal's Soulstone, obviously."
//                           error:&err])
//    
//    {
//    
//        
//        NSLog(@"fcd");
//        
//        
//    }
    
    XMPPJID *JID = [XMPPJID jidWithString:string];
    NSLog(@"%@",[JID full]);
    NSLog(@"Attempting TURN connection to %@", JID);
    [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:JID.domain, nil]];
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:JID];
    [turnSockets addObject:turnSocket];
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    savedict=userdict;
    send=result;
    
    
    
}

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"There was an error sending your file. See the logs."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
 
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:@"Your file was sent successfully."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
               didReceiveSIOffer:(XMPPIQ *)offer
{
    [sender acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
              didSucceedWithData:(NSData *)data
                           named:(NSString *)name
{
   
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:name];
    [data writeToFile:fullPath options:0 error:nil];
    
   
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
    NSError *error;
    
    
    [xmppStream registerWithElements:elements error:&error];
    savedict=dict;
    send=result;
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    if ([[savedict objectForKey:@"action"]isEqualToString:@"signup"])
    {
    NSString *userJID=[NSString stringWithFormat:@"%@@varun.local",[savedict objectForKey:@"username"]];
    XMPPJID *newBuddy = [XMPPJID jidWithString:userJID];
    [xmppRoster addUser:newBuddy withNickname:nil];
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
NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
        
        if (queryElement)
        {
            NSArray *itemElements = [queryElement elementsForName: @"item"];
            NSMutableArray *mArray = [[NSMutableArray alloc] init];
            for (int i=0; i<[itemElements count]; i++)
            {
                NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
                
                
               XMPPJID *user= [XMPPJID jidWithString:jid];
                
                
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
    else if ([[savedict objectForKey:@"action"]isEqualToString:@"sendmessage"])
    {
       
        if ([TURNSocket isNewStartTURNRequest:iq])
        {
            NSLog(@"TURN Connectio started:: to establish:: incoming file transfer request..");
            TURNSocket *turnSocket = [[TURNSocket alloc]initWithStream:sender incomingTURNRequest:iq];
            [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            [turnSockets addObject:turnSocket];
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
            
            resource=[presence fromStr];
            
            
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
