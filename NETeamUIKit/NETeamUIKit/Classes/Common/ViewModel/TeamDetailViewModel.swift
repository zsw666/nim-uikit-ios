// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreMedia
import Foundation
import NEChatKit
import NIMSDK

@objcMembers
open class TeamDetailViewModel: NSObject, NETeamListener {
  let teamRepo = TeamRepo.shared
  private let className = "ContactUserViewModel"
  var teamJoined: ((V2NIMTeam) -> Void)?

  override public init() {
    super.init()
    teamRepo.addTeamListener(self)
  }

  deinit {
    teamRepo.removeTeamListener(self)
  }

  open func applyJoinTeam(_ teamId: String, _ completion: @escaping (V2NIMTeam?, Error?) -> Void) {
    NEALog.infoLog(ModuleName + " " + className, desc: #function + ", teamId: " + teamId)

    teamRepo.applyJoinTeam(teamId: teamId, teamType: .TEAM_TYPE_NORMAL, postscript: nil, completion)
  }

  open func getTeamInfo(_ teamId: String, _ completion: @escaping (V2NIMTeam?, Error?) -> Void) {
    NEALog.infoLog(ModuleName + " " + className, desc: #function + ", teamId: " + teamId)
    teamRepo.getTeamInfo(teamId, .TEAM_TYPE_NORMAL, completion)
  }

  open func onTeamJoined(_ team: V2NIMTeam) {
    DispatchQueue.main.async { [weak self] in
      self?.teamJoined?(team)
    }
  }
}
