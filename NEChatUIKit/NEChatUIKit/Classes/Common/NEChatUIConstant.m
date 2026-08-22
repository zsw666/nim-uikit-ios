// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEChatUIConstant.h"

static NSArray<NSBundle *> *_Nonnull _chatCandidateBundles(void) {
  static NSArray<NSBundle *> *bundles = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSMutableOrderedSet<NSBundle *> *candidates = [NSMutableOrderedSet orderedSet];
    void (^addBundle)(NSBundle *_Nullable) = ^(NSBundle *_Nullable bundle) {
      if (bundle) {
        [candidates addObject:bundle];
      }
    };

    Class chatBaseViewControllerClass = NSClassFromString(@"NEChatUIKit.NEChatBaseViewController");
    if (!chatBaseViewControllerClass) {
      chatBaseViewControllerClass = NSClassFromString(@"NEChatBaseViewController");
    }
    addBundle(chatBaseViewControllerClass ? [NSBundle bundleForClass:chatBaseViewControllerClass]
                                          : nil);

    Class chatUIKitClientClass = NSClassFromString(@"NEChatUIKit.NEChatUIKitClient");
    if (!chatUIKitClientClass) {
      chatUIKitClientClass = NSClassFromString(@"NEChatUIKitClient");
    }
    addBundle(chatUIKitClientClass ? [NSBundle bundleForClass:chatUIKitClientClass] : nil);

    for (NSBundle *framework in [NSBundle allFrameworks]) {
      if ([framework.bundleURL.lastPathComponent containsString:@"NEChatUIKit"]) {
        addBundle(framework);
      }
    }

    addBundle([NSBundle mainBundle]);
    bundles = candidates.count > 0 ? [candidates.array copy] : @[ [NSBundle mainBundle] ];
  });
  return bundles;
}

static BOOL _chatBundleContainsResources(NSBundle *bundle) {
  if (!bundle) {
    return NO;
  }
  if ([bundle URLForResource:@"NIMKitEmoticon" withExtension:@"bundle"]) {
    return YES;
  }
  if ([bundle pathForResource:@"emoji_ios_en" ofType:@"plist"]) {
    return YES;
  }
  return [bundle pathForResource:@"Localizable" ofType:@"strings"
                     inDirectory:@"zh-Hans.lproj"] != nil;
}

static NSBundle *_Nullable _chatBundle(void) {
  static NSBundle *bundle = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    for (NSBundle *candidate in _chatCandidateBundles()) {
      if (_chatBundleContainsResources(candidate)) {
        bundle = candidate;
        break;
      }
    }
    if (!bundle) {
      bundle = _chatCandidateBundles().firstObject ?: [NSBundle mainBundle];
    }
  });
  return bundle;
}

static NSString *NEChatCurrentLanguageRawValue(void) {
  NSString *language = [[NSUserDefaults standardUserDefaults] stringForKey:@"IMKitLanguage"];
  if (language.length > 0) {
    return language;
  }
  NSString *preferred = [NSLocale preferredLanguages].firstObject;
  if ([preferred hasPrefix:@"zh"]) {
    return @"zh-Hans";
  }
  return @"en";
}

NSString *chatLocalizable(NSString *key) {
  NSString *language = NEChatCurrentLanguageRawValue();
  NSString *const missingValue = @"__NEChatUIKitMissing__";
  for (NSBundle *bundle in _chatCandidateBundles()) {
    NSBundle *stringBundle = bundle;
    NSString *lprojPath = [bundle pathForResource:language ofType:@"lproj"];
    if (!lprojPath) {
      NSString *prefix = [[language componentsSeparatedByString:@"-"] firstObject];
      lprojPath = [bundle pathForResource:prefix ofType:@"lproj"];
    }
    if (lprojPath) {
      NSBundle *candidate = [NSBundle bundleWithPath:lprojPath];
      if (candidate) {
        stringBundle = candidate;
      }
    }
    NSString *value = [stringBundle localizedStringForKey:key
                                                    value:missingValue
                                                    table:@"Localizable"];
    if (![value isEqualToString:missingValue]) {
      return value;
    }
  }
  return key;
}

UIImage *_Nullable chatLoadImage(NSString *name) {
  if (name.length == 0) {
    return nil;
  }

  NSBundle *preferredBundle = _chatBundle();
  if (preferredBundle) {
    UIImage *image = [UIImage imageNamed:name
                                inBundle:preferredBundle
           compatibleWithTraitCollection:nil];
    if (image) {
      return image;
    }
  }

  for (NSBundle *bundle in _chatCandidateBundles()) {
    if (bundle == preferredBundle) {
      continue;
    }
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    if (image) {
      return image;
    }
  }

  return nil;
}

NSBundle *_Nullable chatBundle(void) { return _chatBundle(); }

NSString *getJSONStringFromDictionary(NSDictionary<NSString *, id> *dictionary) {
  if (![NSJSONSerialization isValidJSONObject:dictionary]) {
    NSLog(@"not parse to json string");
    return @"";
  }
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
  if (data) {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
  }
  return @"";
}

NSDictionary *_Nullable getDictionaryFromJSONString(NSString *jsonString) {
  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) {
    return nil;
  }
  id obj = [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
  if ([obj isKindOfClass:[NSDictionary class]]) {
    return (NSDictionary *)obj;
  }
  return nil;
}

CGFloat const kScreenInterval = 20.0;
CGFloat const kNavigationHeight = 44.0;
NSString *const ChatUIKitModuleName = @"NEChatUIKit";

CGFloat kScreenWidth = 0;
CGFloat kScreenHeight = 0;

static void NEChatRefreshScreenMetrics(void) {
  CGSize size = [UIScreen mainScreen].bounds.size;
  kScreenWidth = size.width;
  kScreenHeight = size.height;
}

__attribute__((constructor)) static void NEChatInstallScreenMetricObserver(void) {
  @autoreleasepool {
    NEChatRefreshScreenMetrics();
  }
}

CGFloat kUISreenWidthScale(void) { return kScreenWidth() / 375.0; }
CGFloat kUISreenHeightScale(void) { return kScreenHeight() / 667.0; }
CGFloat KStatusBarHeight(void) {
  return [UIApplication sharedApplication].statusBarFrame.size.height;
}

UIFont *TextFont(NSString *fontName, CGFloat fontSize) {
  UIFont *font = [UIFont fontWithName:fontName size:fontSize];
  return font ?: [UIFont systemFontOfSize:fontSize];
}

UIFont *DefaultTextFont(CGFloat fontSize) { return TextFont(@"PingFangSC-Regular", fontSize); }

NSArray<NSString *> *file_audio_support(void) {
  return @[ @"mp3", @"aac", @"wav", @"wma", @"flac" ];
}
NSArray<NSString *> *file_video_support(void) {
  return @[
    @"mp4", @"avi", @"wmv", @"mpeg", @"m4v", @"mov", @"asf", @"flv", @"f4v", @"rmvb", @"rm", @"3gp"
  ];
}
NSArray<NSString *> *file_img_support(void) {
  return @[ @"jpg", @"jpeg", @"png", @"tiff", @"heic", @"gif" ];
}
NSArray<NSString *> *file_xls_support(void) { return @[ @"xls", @"xlsx", @"csv" ]; }
NSArray<NSString *> *file_doc_support(void) { return @[ @"doc", @"docx" ]; }
NSArray<NSString *> *file_ppt_support(void) { return @[ @"ppt", @"pptx" ]; }
NSArray<NSString *> *file_txt_support(void) { return @[ @"txt" ]; }
NSArray<NSString *> *file_zip_support(void) { return @[ @"zip", @"tar", @"rar", @"7z" ]; }
NSArray<NSString *> *file_pdf_support(void) { return @[ @"pdf", @"rtf" ]; }
NSArray<NSString *> *file_html_support(void) { return @[ @"html" ]; }

NSDictionary<NSNumber *, NSString *> *antispamResultCodeDic(void) {
  return @{
    @100 : chatLocalizable(@"failed_message_reson_ornography"),
    @200 : chatLocalizable(@"failed_message_reson_advertising"),
    @260 : chatLocalizable(@"failed_message_reson_advertising_law"),
    @300 : chatLocalizable(@"failed_message_reson_violence_and_terrorism"),
    @400 : chatLocalizable(@"failed_message_reson_prohibited"),
    @500 : chatLocalizable(@"failed_message_reson_political_related"),
    @600 : chatLocalizable(@"failed_message_reson_abuse"),
    @700 : chatLocalizable(@"failed_message_reson_waterlogging"),
    @900 : chatLocalizable(@"failed_message_reson_others"),
    @1000 : chatLocalizable(@"failed_message_reson_value_related"),
  };
}

NSString *const NEMoreCell_ReuseId = @"NEMoreCell";
CGFloat const NEMoreView_Section_Padding = 24.0;
CGFloat const NEMoreCell_Title_Height = 20.0;
CGFloat const NEMoreView_Margin = 16.0;
NSInteger const NEMoreView_Column_Count = 4;

CGSize NEMoreCell_Image_Size(void) { return CGSizeMake(56.0, 56.0); }

UIColor *HexRGBAlpha(NSInteger rgbValue, CGFloat alpha) {
  return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0
                         green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0
                          blue:((CGFloat)(rgbValue & 0xFF)) / 255.0
                         alpha:alpha];
}

UIColor *HexRGB(NSInteger rgbValue) { return HexRGBAlpha(rgbValue, 1.0); }
UIColor *TextNormalColor(void) { return HexRGB(0x333333); }
UIColor *SubTextColor(void) { return HexRGB(0x666666); }
UIColor *PlaceholderTextColor(void) { return HexRGB(0xA6ADB6); }
UIColor *multiForwardLineColor(void) { return HexRGB(0xF0F1F5); }
UIColor *forwardLineColor(void) { return HexRGB(0xE1E6E8); }
UIColor *multiForwardborderColor(void) { return HexRGB(0xE4E9F2); }

NSNotificationName const NENotificationCreateServer = @"qchat.createServer";
NSNotificationName const NENotificationCreateChannel = @"qchat.createChannel";
NSNotificationName const NENotificationUpdateChannel = @"qchat.updateChannel";
NSNotificationName const NENotificationDeleteChannel = @"qchat.deleteChannel";
NSNotificationName const NENotificationLeaveTeamBySelf = @"team.leaveTeamBySelf";
NSNotificationName const NENotificationLogout = @"qchat.logout";
NSNotificationName const NENotificationPopGroupChatVC = @"team.popGroupChatVC";
