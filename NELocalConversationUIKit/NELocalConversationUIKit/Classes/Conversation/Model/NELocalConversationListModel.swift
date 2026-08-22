//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NEChatKit
import NIMSDK
import UIKit

@objcMembers
public class NELocalConversationListModel: NSObject {
  private var locallyReadTime: TimeInterval = 0

  /// 会话
  public var conversation: V2NIMLocalConversation? {
    didSet {
      if oldValue?.conversationId != conversation?.conversationId {
        locallyReadTime = 0
      }
      if let lastMessage = conversation?.lastMessage,
         lastMessage.messageType == .MESSAGE_TYPE_TEXT,
         let text = lastMessage.text {
        let itemContentSize = LocalConversationUIConfig.shared.conversationProperties.itemContentSize > 0 ? LocalConversationUIConfig.shared.conversationProperties.itemContentSize : 13
        lastMessageConent = NEChatKitClient.instance.getEmojString(text,
                                                                   itemContentSize,
                                                                   LocalConversationUIConfig.shared.conversationProperties.itemContentColor)
      } else {
        lastMessageConent = nil
      }
    }
  }

  /// 自定义类型
  public var customType = 0

  /// 最后一条消息内容(包含表情解析)
  var lastMessageConent: NSAttributedString?

  /// 单聊是否在线
  public var p2pOnline: Bool = false

  /// 优先使用 UIKit 已确认的已读状态，避免 SDK 未抛会话变更时继续展示旧未读数。
  public var unreadCount: Int {
    let sdkUnreadCount = conversation?.unreadCount ?? 0
    guard sdkUnreadCount > 0, locallyReadTime > 0 else {
      return sdkUnreadCount
    }
    let lastMessageTime = conversation?.lastMessage?.messageRefer.createTime ?? 0
    return lastMessageTime <= locallyReadTime ? 0 : sdkUnreadCount
  }

  public func markUnreadCountCleared() {
    let lastMessageTime = conversation?.lastMessage?.messageRefer.createTime ?? Date().timeIntervalSince1970
    locallyReadTime = max(locallyReadTime, lastMessageTime)
  }

  public func markUnreadCountCleared(through readTime: TimeInterval) {
    locallyReadTime = max(locallyReadTime, readTime)
  }
}
