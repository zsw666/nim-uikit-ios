// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT CGFloat const chat_cell_margin;
FOUNDATION_EXPORT CGFloat const chat_content_margin;
FOUNDATION_EXPORT CGFloat const chat_headWH;
FOUNDATION_EXPORT CGFloat const chat_timeCellH;
FOUNDATION_EXPORT CGFloat const chat_min_h;
FOUNDATION_EXPORT CGFloat const fun_chat_min_h;
FOUNDATION_EXPORT CGFloat const chat_reply_height;
FOUNDATION_EXPORT CGFloat const fun_chat_reply_height;
FOUNDATION_EXPORT CGFloat const chat_pin_height;
FOUNDATION_EXPORT CGFloat const chat_full_name_height;
FOUNDATION_EXPORT CGFloat const ai_chat_view_height;

CGSize chat_pic_size(void);
CGSize chat_file_size(void);

FOUNDATION_EXPORT CGFloat chat_content_maxW;
#define chat_content_maxW() (chat_content_maxW)

FOUNDATION_EXPORT CGFloat chat_text_maxW;
#define chat_text_maxW() (chat_text_maxW)

FOUNDATION_EXPORT CGFloat audio_max_width;
#define audio_max_width() (audio_max_width)

NS_ASSUME_NONNULL_END
