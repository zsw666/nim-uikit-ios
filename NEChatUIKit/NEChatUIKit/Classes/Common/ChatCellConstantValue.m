// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "ChatCellConstantValue.h"
#import "NEChatUIConstant.h"

CGFloat const chat_cell_margin = 16.0;
CGFloat const chat_content_margin = 8.0;
CGFloat const chat_headWH = 32.0;
CGFloat const chat_timeCellH = 22.0;
CGFloat const chat_min_h = 40.0;
CGFloat const fun_chat_min_h = 42.0;
CGFloat const chat_reply_height = 16.0;
CGFloat const fun_chat_reply_height = 44.0;
CGFloat const chat_pin_height = 16.0;
CGFloat const chat_full_name_height = 16.0;
CGFloat const ai_chat_view_height = 234.0;

CGFloat chat_content_maxW = 0;
CGFloat chat_text_maxW = 0;
CGFloat audio_max_width = 0;

static void NEChatRefreshChatCellConstants(void) {
  chat_content_maxW = kScreenWidth - 156.0;
  chat_text_maxW = chat_content_maxW - 2.0 * chat_content_margin;
  audio_max_width = kScreenWidth <= 325.0 ? 230.0 : 265.0;
}

__attribute__((constructor)) static void NEChatInstallChatCellConstantObserver(void) {
  @autoreleasepool {
    NEChatRefreshChatCellConstants();
  }
}

CGSize chat_pic_size(void) { return CGSizeMake(150.0, 200.0); }

CGSize chat_file_size(void) { return CGSizeMake(254.0, 56.0); }
