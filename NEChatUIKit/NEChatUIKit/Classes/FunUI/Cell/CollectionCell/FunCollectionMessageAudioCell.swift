//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers
open
class FunCollectionMessageAudioCell: NEBaseCollectionMessageAudioCell {
  override open func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override open func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  /// 初始化的生命周期
  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  /// 反序列化支持回调
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override open func setupCommonUI() {
    super.setupCommonUI()
    setFunStyle()
    let image = ChatUIConfig.shared.messageProperties.leftBubbleBg ?? UIImage.ne_imageNamed(name: "fun_pin_message_audio_bg")
    if let backgroundImageCapInsets = ChatUIConfig.shared.messageProperties.backgroundImageCapInsets {
      bubbleImage.image = image?.resizableImage(withCapInsets: backgroundImageCapInsets)
    } else {
      bubbleImage.image = image
      bubbleImage.contentMode = .scaleAspectFill
    }
  }
}
