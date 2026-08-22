// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEChatKit/NEChatKit.h>
#import <UIKit/UIKit.h>

#if __has_include("ChatInputViewDelegate.h")
#import "ChatInputViewDelegate.h"
#endif

#if __has_include("MessageAtInfoModel.h")
#import "MessageAtInfoModel.h"
#endif

#if __has_include("NETeamUserManager.h")
#import "NETeamUserManager.h"
#endif

#if __has_include("NETranslateLanguageManager.h")
#import "NETranslateLanguageManager.h"
#endif

#ifndef ChatMessageStatusSuccessed
#define ChatMessageStatusSuccessed ChatSendMessageStatusSuccessed
#endif

#ifndef ChatMessageStatusSending
#define ChatMessageStatusSending ChatSendMessageStatusSending
#endif

#ifndef ChatMessageStatusFailed
#define ChatMessageStatusFailed ChatSendMessageStatusFailed
#endif

#ifndef ChatMessageStatusSendingFailed
#define ChatMessageStatusSendingFailed ChatSendMessageStatusSendingFailed
#endif

NS_ASSUME_NONNULL_BEGIN

NSString *chatLocalizable(NSString *key);
UIImage *_Nullable chatLoadImage(NSString *name);
NSBundle *_Nullable chatBundle(void);

NSString *getJSONStringFromDictionary(NSDictionary<NSString *, id> *dictionary)
    NS_SWIFT_UNAVAILABLE("Use the Swift getJSONStringFromDictionary(_:) helper instead.");
NSDictionary *_Nullable getDictionaryFromJSONString(NSString *jsonString)
    NS_SWIFT_UNAVAILABLE("Use the Swift getDictionaryFromJSONString(_:) helper instead.");

@protocol ViewModelDelegate <NSObject>
- (void)dataDidChange;
- (void)dataDidError:(NSError *)error;
@optional
- (void)dataNoMore;
@end

FOUNDATION_EXPORT CGFloat const kScreenInterval;
FOUNDATION_EXPORT CGFloat const kNavigationHeight;
FOUNDATION_EXPORT CGFloat kScreenWidth;
FOUNDATION_EXPORT CGFloat kScreenHeight;
#define kScreenWidth() (kScreenWidth)
#define kScreenHeight() (kScreenHeight)
CGFloat kUISreenWidthScale(void);
CGFloat kUISreenHeightScale(void);
CGFloat KStatusBarHeight(void);

UIFont *TextFont(NSString *fontName, CGFloat fontSize);
UIFont *DefaultTextFont(CGFloat fontSize);

FOUNDATION_EXPORT NSString *const ChatUIKitModuleName;
#define ModuleName ChatUIKitModuleName

FOUNDATION_EXPORT NSArray<NSString *> *file_audio_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_video_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_img_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_xls_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_doc_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_ppt_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_txt_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_zip_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_pdf_support(void);
FOUNDATION_EXPORT NSArray<NSString *> *file_html_support(void);

NSDictionary<NSNumber *, NSString *> *antispamResultCodeDic(void);

FOUNDATION_EXPORT NSString *const NEMoreCell_ReuseId;
FOUNDATION_EXPORT CGFloat const NEMoreView_Section_Padding;
FOUNDATION_EXPORT CGFloat const NEMoreCell_Title_Height;
FOUNDATION_EXPORT CGFloat const NEMoreView_Margin;
FOUNDATION_EXPORT NSInteger const NEMoreView_Column_Count;
CGSize NEMoreCell_Image_Size(void);

UIColor *HexRGB(NSInteger rgbValue);
UIColor *HexRGBAlpha(NSInteger rgbValue, CGFloat alpha);
FOUNDATION_EXPORT UIColor *TextNormalColor(void);
FOUNDATION_EXPORT UIColor *SubTextColor(void);
FOUNDATION_EXPORT UIColor *PlaceholderTextColor(void);
FOUNDATION_EXPORT UIColor *multiForwardLineColor(void);
FOUNDATION_EXPORT UIColor *forwardLineColor(void);
FOUNDATION_EXPORT UIColor *multiForwardborderColor(void);

FOUNDATION_EXPORT NSNotificationName const NENotificationCreateServer;
FOUNDATION_EXPORT NSNotificationName const NENotificationCreateChannel;
FOUNDATION_EXPORT NSNotificationName const NENotificationUpdateChannel;
FOUNDATION_EXPORT NSNotificationName const NENotificationDeleteChannel;
FOUNDATION_EXPORT NSNotificationName const NENotificationLeaveTeamBySelf;
FOUNDATION_EXPORT NSNotificationName const NENotificationLogout;
FOUNDATION_EXPORT NSNotificationName const NENotificationPopGroupChatVC;

NS_ASSUME_NONNULL_END
