//
//  MyWebSocket.h
//  NaveenChatApp
//
//  Created by Techahead on 10/06/14.
//  Copyright (c) 2013 Techahead. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRWebSocket.h"


//=========Headers of Bytes==============
#define kIsGroupChat @"isGroupChat"
#define kIsGroup    @"isGroup"
#define kIsClass   @"isClass"
#define kIsmute   @"ismute"


#define kFromId @"fromId"
#define kToId @"toId"
#define kChatId @"chatId"
#define kDeviceTimeStamp @"deviceTimeStamp"
#define kServerTimeStamp @"serverTimeStamp"
#define kTextByte @"textByte"
#define kImageByte @"imageByte"
#define kVideoByte @"videoByte"
#define kAttachmentType @"attachmentType"
#define kText @"text"
#define kImage @"image"
#define kVideo @"video"
#define kAttachment @"attachment"
#define kIsSessionStart @"isSessionStart"
//=========================================

@protocol MyWebSocketDelegate <NSObject>

@optional
- (void)didReceiveDataFromOpponent:(NSMutableDictionary *)data;
- (void)didReceiveTextFromOpponent:(NSString *)message;
@end

@class ChatViewController;

@interface MyWebSocket : NSObject <SRWebSocketDelegate>
{
    //SRWebSocket *_webSocket;
}


//@property (nonatomic, retain) WebSocket* webSocket;
@property(nonatomic, strong) id<MyWebSocketDelegate> webSocketDelegate;
@property(nonatomic, strong) SRWebSocket *webSocket;
@property(nonatomic,copy) void(^GetChatData)(id data);;


+ (MyWebSocket *)sharedInstance;
- (void)connectSocketWithBlock:(void(^)(BOOL connected,NSError *error))block;
- (void)sendData:(NSData *)data acknowledge:(void(^)(NSData *data, NSError *error))block;
- (void)sendDictionary:(NSDictionary *)dict acknowledge:(void(^)(NSString *data, NSError *error))block;
- (void)sendText:(NSString *)message acknowledge:(void(^)(NSString *message, NSError *error))block;
- (void)testInternetConnection;
- (void)SendMessage:(NSDictionary *) dictData;
- (void)SendMessageJson:(NSDictionary *) dict;
- (void)ConnectSocketFirst;
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
- (void)_reconnect;
- (void)connectSocket;
@end
