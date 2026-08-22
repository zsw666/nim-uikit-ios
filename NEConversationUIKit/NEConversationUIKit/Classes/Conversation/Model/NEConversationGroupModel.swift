// Copyright (c) 2026 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NIMSDK

@objc
public enum NEConversationGroupType: Int {
  case all
  case atMe
  case unread
  case custom
}

@objcMembers
open class NEConversationGroupModel: NSObject {
  public let type: NEConversationGroupType
  public var groupId: String
  public var name: String
  public var unreadCount: Int
  public var sdkGroup: V2NIMConversationGroup?

  public init(type: NEConversationGroupType,
              groupId: String,
              name: String,
              unreadCount: Int = 0,
              sdkGroup: V2NIMConversationGroup? = nil) {
    self.type = type
    self.groupId = groupId
    self.name = name
    self.unreadCount = unreadCount
    self.sdkGroup = sdkGroup
    super.init()
  }

  public var canEdit: Bool {
    type == .custom
  }

  public var canHide: Bool {
    type != .all
  }

  public var canDrag: Bool {
    type != .all
  }

  public var displayName: String {
    guard unreadCount > 0 else {
      return name
    }
    let displayCount = unreadCount > 99 ? "99+" : String(unreadCount)
    return "\(name)(\(displayCount))"
  }

  public static let allId = "conversation_group_all"
  public static let atMeId = "conversation_group_at_me"
  public static let unreadId = "conversation_group_unread"
}

struct NEConversationGroupLocalConfigItem: Codable, Equatable {
  let groupId: String
  var hidden: Bool
  var order: Int
}

struct NEConversationGroupLocalConfig: Codable {
  var items: [NEConversationGroupLocalConfigItem]
}
