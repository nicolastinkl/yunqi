//
//  RemoteImgOperator.m
//  RemoteImgListOperatorDemo
//
//  Created by tinkl on 14-1-7.
//  Copyright (c) 2014年 tinkl. All rights reserved.
//

#import "RemoteImgOperator.h"
#import "XCAlbumAdditions.h"
#import "MLNetworkingManager.h"
#import "FCMessage.h"
#import "CoreData+MagicalRecord.h"
#import "UIImage+WebP.h"
#import "UIImage+Resize.h"

@protocol DownloadImgProgressDelegate <NSObject>

- (void)setProgress:(float)newProgress;

@end

@interface RemoteImgOperator ()

@property (nonatomic, readonly) AFHTTPRequestOperation *m_objAFOper;
@property (nonatomic, readonly) id <DownloadImgProgressDelegate> downloadProgressDelegate;

@end


@implementation RemoteImgOperator
@synthesize delegate;
@synthesize m_objAFOper = _objAFOper;
@synthesize downloadProgressDelegate;

- (id)init
{
    self = [super init];
    if (self)
    {
    }else{}
    return self;
}

- (void)dealloc
{
    if (_objAFOper)
    {
        [_objAFOper cancel];
        _objAFOper = nil;
    }else{}
    
    delegate = nil;
    downloadProgressDelegate = nil;
}

- (BOOL)sendMessage:(NSString *)strGUID withDict:(NSMutableDictionary * ) dict
{
    return [self sendMessage:strGUID withDict:dict progressDelegate:nil];
}

- (BOOL)sendMessage:(NSString *)strGUID withDict:(NSMutableDictionary * ) dict progressDelegate:(id)progress
{
    BOOL bRet = NO;
    
    [self cancelRequest];
    if (strGUID && (strGUID.length > 0))
    {
        bRet = YES;
        
        [self cancelRequest];
        downloadProgressDelegate = progress;
        
        __block NSString * guid = [strGUID copy];
        __weak typeof(self) blockSelf = self;
        int messagetype = [DataHelper getIntegerValue:dict[@"messagetype"] defaultValue:0];
        NSString * userID = [DataHelper getStringValue:dict[@"userid"] defaultValue:@""];
        NSString * content = [DataHelper getStringValue:dict[@"text"] defaultValue:@""];
        NSString * strSrcURL = [DataHelper getStringValue:dict[@"fileSrc"] defaultValue:@""];
        switch (messagetype) {
            case messageType_text:
            case messageType_emj:
            {                
                NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
                [params setValue:userID forKey:@"weChatId"];
                [params setValue:@{@"content":content,@"msgType":@"text"} forKey:@"message"];
                [params setValue:strGUID forKey:@"messageId"]; //new message
                
                [[DAHttpClient sharedDAHttpClient] postRequestWithParameters:params Action:@"AdminApi/WeChat/SendMessage" success:^(id response) {
                    int errorCode  = [DataHelper getIntegerValue:response[@"code"] defaultValue:-1];
                    if (errorCode == 200) {
                        dict[@"messageId"] = strGUID;
                        
                        if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgSuccess:fromGuid:)])
                        {
                            // delegate 通知获取成功
                            [blockSelf.delegate sendMessage:blockSelf sendMsgSuccess:dict fromGuid:guid];
                        }
                    }else{
                        if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgFailed:fromGuid:)])
                        {
                            // delegate 通知获取失败
                            [blockSelf.delegate sendMessage:blockSelf sendMsgFailed:dict fromGuid:guid];
                        }
                    }
//                    NSString * messageId = [tools getStringValue:dic[@"msgid"] defaultValue:nil];
                } error:^(NSInteger index) {
                    //error ..... session not found
                    if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgFailed:fromGuid:)])
                    {
                        // delegate 通知获取失败
                        [blockSelf.delegate sendMessage:blockSelf sendMsgFailed:dict fromGuid:guid];
                    }
                }];
                /*
                NSDictionary * parames = @{@"uid":userID,@"content":content};
                [[MLNetworkingManager sharedManager] sendWithAction:@"message.send" parameters:parames success:^(MLRequest *request, id responseObject) {
                    // {"push": false, "errno": 1, "result": {}, "cdata": "MWUEM", "error": "session not found"}
                    if ([responseObject[@"errno"] intValue] == 0) {
                        
                        NSDictionary * dic = responseObject[@"result"];
                        NSString * messageId = [tools getStringValue:dic[@"msgid"] defaultValue:nil];
                        if (messageId) {
                            
                            dict[@"messageId"] = messageId;
                            
                            if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgSuccess:fromGuid:)])
                            {
                                // delegate 通知获取成功
                                [blockSelf.delegate sendMessage:blockSelf sendMsgSuccess:dict fromGuid:guid];
                            }
                        }
                    }else{
                        //error ..... session not found
                        if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgFailed:fromGuid:)])
                        {
                            // delegate 通知获取失败
                            [blockSelf.delegate sendMessage:blockSelf sendMsgFailed:dict fromGuid:guid];
                        }
                    }
                    
                    
                } failure:^(MLRequest *request, NSError *error) {
                    if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgFailed:fromGuid:)])
                    {
                        // delegate 通知获取失败
                        [blockSelf.delegate sendMessage:blockSelf sendMsgFailed:dict fromGuid:guid];
                    }
                }];*/
            }
                break;
                
            case messageType_image:
            {
                //image 1是图片，2是声音，3是视频  4 map
                [self setuploadRemoteFile:guid FromURL:strSrcURL fileType:1 withParems:dict];
            }
                break;
            case messageType_map:
            {
                    //image map
                [self setuploadRemoteFile:guid FromURL:strSrcURL fileType:1 withParems:dict];
            }
                break;
            case messageType_audio:
            {
                    // file
               [self setuploadRemoteFile:guid FromURL:strSrcURL fileType:2 withParems:dict];
            }
                break;
            case messageType_contacts:
            {
                    // object contacts
            }
                break;
            default:
                break;
        }
        
        
    }
    else
    {
        bRet = NO;
    }
    
    return bRet;
}

- (void)cancelRequest
{
    if (_objAFOper)
    {
        [_objAFOper cancel];
        _objAFOper = nil;
    }else{}
}

- (void)setProgressDelegate:(id)progress
{
    downloadProgressDelegate = progress;
}

- (id)getProgressDelegate
{
    return downloadProgressDelegate;
}

/**
 *   所有类型文件上传 class
 *
 *  @param strSrcURL URL
 */
-(void) setuploadRemoteFile:(NSString * ) guid FromURL:(NSString *)strSrcURL fileType:(int) typeindex withParems:(NSMutableDictionary* ) parems
{
    __weak typeof(self) blockSelf = self;
    //获取上传token  有效时间 3600 S  = 1 hour....
    //MRAK: that can be upload every files
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    NSString * userID = [DataHelper getStringValue:parems[@"userid"] defaultValue:@""];
    [parameters setValue:userID  forKey:@"weChatId"];
    if (typeindex == 1) {
        //image
        [parameters setValue:@{@"msgType":@"image",@"mediaPath":strSrcURL} forKey:@"message"];
    }else if(typeindex == 2){
        [parameters setValue:@{@"msgType":@"voice",@"mediaPath":strSrcURL} forKey:@"message"];
    }
    [parameters setValue:guid  forKey:@"messageId"];
    
    
    __block NSData * FileData;
    AFHTTPRequestOperation * operation =  [manager POST:[NSString stringWithFormat:@"%@%@",[USER_DEFAULT stringForKey:KeyChain_yunqi_account_notifyServerhostName],@"/AdminApi/MediaManager/MediaUpload"] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 1是图片，2是声音，3是视频
        switch (typeindex) {
            case 1:
            {
                // 图片压缩处理
                UIImage * image = [UIImage imageWithContentsOfFile:strSrcURL];
                float quality;
                if (image.size.height > image.size.width) {
                     quality = image.size.height/image.size.width;
                }else{
                     quality = image.size.width/image.size.height;
                }
                quality = quality/2;
                if (quality > 1) {
                    quality = .5;
                }
                UIImage * newimage = [image resizedImage:CGSizeMake(image.size.width * quality, image.size.height * quality) interpolationQuality:kCGInterpolationDefault];
                NSData * FileData = UIImageJPEGRepresentation(newimage, 0.5);
                if (!FileData) {
                    FileData  = UIImageJPEGRepresentation(image, 0.5);
                }
//                NSData *FileData  =  [UIImage imageToWebP:newimage quality:75.0];
                [formData appendPartWithFileData:FileData name:@"mediaPath" fileName:@"mediaPath" mimeType:@"image/jpeg"];
              
            }
                break;
            case 2:
            {
                FileData = [NSData dataWithContentsOfFile:strSrcURL];
                [formData appendPartWithFileData:FileData name:@"mediaPath" fileName:@"mediaPath" mimeType:@"audio/amr-wb"]; //录音
            }
                break;
            case 3:
            {
                FileData = [NSData dataWithContentsOfFile:strSrcURL];
                [formData appendPartWithFileData:FileData name:@"mediaPath" fileName:@"mediaPath" mimeType:@"audio/mp4-wb"]; //视频
            }
                break;
            default:
                break;
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SLog(@"responseObject :%@",responseObject);
        if ([responseObject[@"code"] intValue] == 200) {
//            NSDictionary * dic = responseObject[@"result"];
//            NSString * messageId = [tools getStringValue:dic[@"msgid"] defaultValue:@""];
//            NSString *url = [tools getStringValue:dic[@"url"] defaultValue:@""];
            parems[@"messageId"]  = guid;
            parems[@"url"]  = strSrcURL;
            if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgSuccess:fromGuid:)])
            {
                // delegate 通知获取成功
                [blockSelf.delegate sendMessage:blockSelf sendMsgSuccess:parems fromGuid:guid];
            }
        }else{
            if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgFailed:fromGuid:)])
            {
                // delegate 通知获取失败
                [blockSelf.delegate sendMessage:blockSelf sendMsgFailed:parems fromGuid:guid];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(sendMessage:sendMsgFailed:fromGuid:)])
        {
            // delegate 通知获取失败
            [blockSelf.delegate sendMessage:blockSelf sendMsgFailed:parems fromGuid:guid];
        }
    }];
    [operation start];
}




#pragma mark - 获取文件大小
- (NSInteger) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}








@end
