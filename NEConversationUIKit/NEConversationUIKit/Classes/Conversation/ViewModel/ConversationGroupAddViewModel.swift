// Copyright (c) 2026 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NEChatKit
import NIMSDK

@objcMembers
open class ConversationGroupAddViewModel: NSObject {
  public private(set) var allData = [NEConversationListModel]()
  public private(set) var displayData = [NEConversationListModel]()
  public private(set) var selectedIds = Set<String>()
  public var offset: Int64 = 0
  public var finished = false
  public var pageSize = 100
  public let groupId: String
  public var existingCount: Int { existingIds.count }

  private let existingIds: Set<String>
  private let conversationRepo = ConversationRepo.shared
  private var keyword = ""
  private var isLoading = false

  public init(groupId: String, existingIds: Set<String>) {
    self.groupId = groupId
    self.existingIds = existingIds
    super.init()
  }

  open func loadMore(_ completion: @escaping (NSError?, Bool) -> Void) {
    guard finished == false, isLoading == false else {
      return
    }
    isLoading = true
    conversationRepo.getConversationList(offset, pageSize) { [weak self] conversations, nextOffset, finished, error in
      guard let self = self else {
        return
      }
      self.isLoading = false
      if let nextOffset = nextOffset {
        self.offset = nextOffset
      }
      if error == nil {
        self.finished = finished ?? true
      }
      if let conversations = conversations {
        let models = conversations.compactMap { conversation -> NEConversationListModel? in
          guard self.existingIds.contains(conversation.conversationId) == false else {
            return nil
          }
          let model = NEConversationListModel()
          model.conversation = conversation
          return model
        }
        self.allData.append(contentsOf: models)
        self.applySearch()
      }
      completion(error, self.finished)
    }
  }

  open func search(_ text: String?) {
    keyword = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    applySearch()
  }

  private func applySearch() {
    guard keyword.isEmpty == false else {
      displayData = allData
      return
    }
    displayData = allData.filter { model in
      let name = model.conversation?.name ?? ""
      return name.localizedCaseInsensitiveContains(keyword)
    }
  }

  open func toggle(_ conversationId: String) {
    if selectedIds.contains(conversationId) {
      selectedIds.remove(conversationId)
    } else {
      selectedIds.insert(conversationId)
    }
  }
}
