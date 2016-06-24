//
//  MyWebSocket.m
//  NaveenChatApp
//
//  Created by Techahead on 10/06/14.
//  Copyright (c) 2013 Techahead. All rights reserved.
//


#import "MyWebSocket.h"
#import "ChatScreenViewController.h"



typedef void(^Connect)(BOOL connected,NSError *error);
typedef void(^SendData)(NSData *data, NSError *error);
typedef void(^SendText)(NSString *message, NSError *error);
typedef void(^Acknowledgement)(NSString *ack, NSError *error);


@interface MyWebSocket ()

@property(nonatomic,copy) Connect connectBlock;
@property(nonatomic,copy) SendData sendDataBlock;
@property(nonatomic,copy) SendText sendTextBlock;
@property(nonatomic,copy) Acknowledgement acknowledgementBlock;

@end

@implementation MyWebSocket



+ (MyWebSocket *)sharedInstance
{
    static MyWebSocket *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MyWebSocket alloc] init];
    });
    
    return _sharedInstance;
}


#pragma mark Lifecycle

- (void)connectSocket
{
    
    if (_webSocket)
    {
        _webSocket.delegate = nil;
        [_webSocket close];
    }
    
    [defaults setBool:NO forKey:kIsSocketOpen];
    [defaults synchronize];
    //_webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:9000/chat"]]];
   // NSString *strChatURL = @"ws://staging10.techaheadcorp.com/tedbuddy/api/";
    NSString *strChatURL = @"ws://studebuddies.com/api/";
    
    NSLog(@"URL::%@",[NSString stringWithFormat:@"%@ChatApplication/Get?userid=%@&chatToId=0&isGroup=False",kSocketURL,[defaults objectForKey:kUserId]]);
//    NSString *strChatURL = @"ws://10.11.5.102:80/api/";
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@ChatApplication/Get?userid=%@&chatToId=0&isGroup=False",kSocketURL,[defaults objectForKey:kUserId]]]];

    
//    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"ws://staging10.techaheadcorp.com:80/tedbuddy/api/ChatApplication/Get?userid=23"]];
    //staging10.techaheadcorp.com:80/tedbuddy/api/ChatApplication/Get?userid=23
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    // NSString *socketUrl = [NSString stringWithFormat:@"ws://203.123.36.132/chatserver/serv.php"];
    
    _webSocket.delegate = self;
    DLog(@"Opening Connection...");
    [_webSocket open];
    
       
}
-(void)ConnectSocketFirst
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *strUserId=[kUserDefaults valueForKey:kUserId];
//        NSString *strUser=[NSString stringWithFormat:@"FT_CONNECT||||%@||||^^^^^^",strUserId];
//        [_webSocket send:strUser];
//  
//    });
   }

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    DLog(@"Websocket Connected");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *strUserId=[defaults valueForKey:kUserId];
        
//        NSString *strUser=[NSString stringWithFormat:@"FT_CONNECT||||%@||||^^^^^^",strUserId];
//        [_webSocket send:strUser];
        
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    DLog(@":( Websocket Failed With Error %@", error);
    
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    
    NSString *fromIdString,*toIdString,*isGroupString,*messageTypeString,*deviceTimeStampString,*messageString,*userId;
    
    if([message isKindOfClass:[NSData class]])
    {
        NSData *mainData = message;
        long long int fromId;
        NSData *data1 = [mainData subdataWithRange:NSMakeRange(0, 8)];
        [data1 getBytes:&fromId length:8];
        fromIdString=[NSString stringWithFormat:@"%llu",fromId];
        userId =[NSString stringWithFormat:@"%lld",fromId];
        
        long long int toId;
        NSData *data2 = [mainData subdataWithRange:NSMakeRange(8, 8)];
        [data2 getBytes:&toId length:8];
        toIdString=[NSString stringWithFormat:@"%llu",toId];
        DLog(@"toIdString %@",toIdString);
        
        long long int isGroup;
        NSData *data3 = [mainData subdataWithRange:NSMakeRange(16, 8)];
        [data3 getBytes:&isGroup length:8];
        isGroupString=[NSString stringWithFormat:@"%llu",isGroup];
        DLog(@"isGroupString %@",isGroupString);
        
        long long int messageType;
        NSData *data4 = [mainData subdataWithRange:NSMakeRange(24, 8)];
        [data4 getBytes:&messageType length:8];
        messageTypeString=[NSString stringWithFormat:@"%llu",messageType];
        DLog(@"messageTypeString %@",messageTypeString);
        
        long long int deviceTimeStamp;
        NSData *data5 = [mainData subdataWithRange:NSMakeRange(32, 8)];
        [data5 getBytes:&deviceTimeStamp length:8];
        deviceTimeStampString=[NSString stringWithFormat:@"%llu",deviceTimeStamp];
        DLog(@"deviceTimeStampString %@",deviceTimeStampString);
        
        
        long long int messageBytes;
        NSData *data6 = [mainData subdataWithRange:NSMakeRange(40, [mainData length] - 40)];
        [data6 getBytes:&messageBytes length:8];
        messageString=[[NSString alloc] initWithData:data6 encoding:NSUTF8StringEncoding];
        DLog(@"messageString %@",messageString);
    }else
    {
        NSArray *dataArray = [message componentsSeparatedByString:@","];
        userId=[dataArray objectAtIndex:0];
        fromIdString=[dataArray objectAtIndex:0];
        toIdString=[dataArray objectAtIndex:1];
        isGroupString=[dataArray objectAtIndex:2];
        messageTypeString=[dataArray objectAtIndex:3];
        deviceTimeStampString=[dataArray objectAtIndex:4];
        messageString=[dataArray objectAtIndex:5];
    }
      
    
    
    NSDate *dateNow = [Utils getUTCTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSString *strDate = [formatter stringFromDate:dateNow];
    
    
    NSDictionary *dictAddToChat = @{kCreatedDateChat:strDate,
                                    kProfileImage:@"",
                                    kUserId:userId,
                                    kToId:toIdString,
                                    kMessageSmall:messageString,
                                    kChatId:@"",
                                    @"messageType":messageTypeString,
                                    kUserName:@"",
                                    @"timeAgo":@"",
                                    kIsGroup:isGroupString
                                    };
//    [Utils showAlertViewWithMessage:messageString];
    
    if (_GetChatData)
    {
        _GetChatData(dictAddToChat);
    }
    else
    {
        
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    DLog(@"WebSocket closed");
    _webSocket = nil;
    [[MyWebSocket sharedInstance] connectSocket];
    [[MyWebSocket sharedInstance]ConnectSocketFirst];
}

#pragma  mark:methods
-(void)SendMessage:(NSDictionary *) dict
{
    NSMutableData *data = [NSMutableData data];
    

    NSString *fromId = [dict objectForKey:kFromId];
    long long int fromIdInt = [fromId longLongValue];
    [data appendBytes:&fromIdInt length:8];
    
    NSString *toId = [dict objectForKey:kToId];
    long long int toIdInt = [toId longLongValue];
    [data appendBytes:&toIdInt length:8];
    
    NSString *isGroup = [dict objectForKey:@"isGroup"];
    long long int isGroupInt = [isGroup longLongValue];
    [data appendBytes:&isGroupInt length:8];
    
    NSString *messageType = [dict objectForKey:@"messageType"];
    long long int messageTypeInt = [messageType longLongValue];
    [data appendBytes:&messageTypeInt length:8];
    
    NSString *deviceTimeStamp = [dict objectForKey:@"deviceTimeStamp"];
    long long int deviceTimeStampInt = [deviceTimeStamp longLongValue];
    [data appendBytes:&deviceTimeStampInt length:8];
    
    NSString *message = [dict objectForKey:@"message"];
    NSData *textData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:textData];
    NSString *datastr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Data++++++>%@",datastr);

    [_webSocket send:data];
}
-(void)SendMessageJson:(NSDictionary *) dict
{
    NSString *fromId = [dict objectForKey:kFromId];
    NSString *toId = [dict objectForKey:kToId];
    NSString *isGroup = [dict objectForKey:kIsGroup];
    NSString *sessionStart = [dict objectForKey:kIsSessionStart];
    
    NSDictionary *dictSendChat = @{@"userId": fromId,@"chatToId":toId,@"isGroup":isGroup,kIsSessionStart:sessionStart};
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictSendChat options:0 error:nil] encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}


@end
