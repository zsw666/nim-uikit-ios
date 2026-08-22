
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NEChatKit
import NIMSDK
import UIKit

@objcMembers
open class NEBaseTeamUserCell: UICollectionViewCell {
  public var user: NETeamMemberInfoModel? {
    didSet {
      if let userId = user?.nimUser?.user?.accountId {
        if let u = NEFriendUserCache.shared.getFriendInfo(userId) {
          let url = u.user?.avatar
          let accountId = u.user?.accountId ?? ""
          let name = user?.getShortName(u.showName(false) ?? accountId) ?? ""
          userHeaderView.configHeadData(headUrl: url, name: name, uid: accountId)
        } else {
          let url = user?.nimUser?.user?.avatar
          let accountId = user?.nimUser?.user?.accountId ?? ""
          let name = user?.getShortName(user?.nimUser?.showName(false) ?? accountId) ?? ""
          userHeaderView.configHeadData(headUrl: url, name: name, uid: accountId)
        }
      }
    }
  }

  public lazy var userHeaderView: NEUserHeaderView = {
    let headerView = NEUserHeaderView(frame: .zero)
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.titleLabel.font = NEConstant.defaultTextFont(11.0)
    headerView.clipsToBounds = true
    return headerView
  }()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  open func setupUI() {
    contentView.addSubview(userHeaderView)
  }
}
