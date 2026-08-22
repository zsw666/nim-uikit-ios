
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers
open class NEBaseConversationSearchCell: TextBaseCell {
  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  public var searchModel: ConversationSearchListModel? {
    didSet {
      if let _ = searchModel {
        if let userFriend = searchModel?.userInfo {
          let url = userFriend.user?.avatar
          let accountId = userFriend.user?.accountId ?? ""
          let name = userFriend.user?.name ?? accountId
          headImageView.configHeadData(headUrl: url, name: name, uid: accountId)
          updateFriendDisplay(userFriend)
        }

        if let teamInfo = searchModel?.team {
          let url = teamInfo.avatar
          let name = teamInfo.getShortName()
          let accountId = teamInfo.teamId
          headImageView.configHeadData(headUrl: url, name: name, uid: accountId)

          titleLabel.text = teamInfo.getShowName()
          subTitleLabel.text = nil
        }
      }
    }
  }

  public var searchText: String = "" {
    didSet {
      if let userFriend = searchModel?.userInfo {
        updateFriendDisplay(userFriend)
      }
      applyHighlight(to: titleLabel)
      applyHighlight(to: subTitleLabel)
      let hasSubtitle = !(subTitleLabel.text ?? "").isEmpty
      subTitleLabel.isHidden = !hasSubtitle
      titleLabelTopAnchor?.isActive = hasSubtitle
      titleLabelCenterYAnchor?.isActive = !hasSubtitle
    }
  }

  private func updateFriendDisplay(_ userFriend: NEUserWithFriend) {
    let displayNames = [
      userFriend.friend?.alias ?? "",
      userFriend.user?.name ?? "",
      userFriend.user?.accountId ?? "",
    ].filter { !$0.isEmpty }
    let title = displayNames.first
    let matchedName = displayNames.first { $0.contains(searchText) }
    let subtitle = matchedName == title ? displayNames.dropFirst().first : matchedName
    titleLabel.text = title
    subTitleLabel.text = subtitle == title ? nil : subtitle
    subTitleLabel.isHidden = subTitleLabel.text?.isEmpty != false
    titleLabelTopAnchor?.isActive = !subTitleLabel.isHidden
    titleLabelCenterYAnchor?.isActive = subTitleLabel.isHidden
  }

  private func applyHighlight(to label: UILabel) {
    guard let text = label.text else {
      label.attributedText = nil
      return
    }
    let attributedStr = NSMutableAttributedString(string: text)
    let range = attributedStr.mutableString.range(of: searchText)
    if range.location != NSNotFound {
      attributedStr.addAttribute(.foregroundColor, value: getRangeTextColor(), range: range)
    }
    label.attributedText = attributedStr
  }

  open func getRangeTextColor() -> UIColor {
    UIColor.ne_normalTheme
  }
}
