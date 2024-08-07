// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NEChatKit
import NECoreKit
import UIKit

@objcMembers
open class ContactViewController: NEBaseContactViewController {
  override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
    var contactHeaders = [ContactHeadItem]()
    if NEKitContactConfig.shared.ui.showHeader {
      contactHeaders = [
        ContactHeadItem(
          name: localizable("validation_message"),
          imageName: "valid",
          router: ValidationMessageRouter,
          color: UIColor(hexString: "#60CFA7")
        ),
        ContactHeadItem(
          name: localizable("blacklist"),
          imageName: "blackName",
          router: ContactBlackListRouter,
          color: UIColor(hexString: "#53C3F3")
        ),
      ]

      if IMKitConfigCenter.shared.enableTeam {
        contactHeaders.append(ContactHeadItem(
          name: localizable("my_teams"),
          imageName: "group",
          router: ContactTeamListRouter,
          color: UIColor(hexString: "#BE65D9")
        ))
      }

      if IMKitConfigCenter.shared.enableAIUser {
        contactHeaders.append(ContactHeadItem(
          name: localizable("my_ai_user"),
          imageName: "aiUser",
          router: ContactAIUserListRouter,
          color: UIColor(hexString: "#BE65D9")
        ))
      }

      if let headerDataCallback = NEKitContactConfig.shared.ui.headerData {
        headerDataCallback(contactHeaders)
      }
    }
    viewModel = ContactViewModel(contactHeaders: contactHeaders)
    cellRegisterDic = [
      ContactCellType.ContactPerson.rawValue: ContactTableViewCell.self,
      ContactCellType.ContactOthers.rawValue: ContactTableViewCell.self,
    ]
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override open func commonUI() {
    super.commonUI()

    tableView.register(
      ContactSectionView.self,
      forHeaderFooterViewReuseIdentifier: "\(NSStringFromClass(ContactSectionView.self))"
    )

    for (key, value) in cellRegisterDic {
      tableView.register(value, forCellReuseIdentifier: "\(key)")
    }
  }

  override open func getFindFriendViewController() -> NEBaseFindFriendViewController {
    FindFriendViewController()
  }

  override open func tableView(_ tableView: UITableView,
                               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let info = viewModel.contacts[indexPath.section].contacts[indexPath.row]
    let reusedId = "\(info.contactCellType)"
    let cell = tableView.dequeueReusableCell(withIdentifier: reusedId, for: indexPath)

    if let c = cell as? ContactTableViewCell {
      if IMKitConfigCenter.shared.onlineStatusEnable {
        if indexPath.section != 0 {
          c.avatarImageView.alpha = 0.5
          if let accountId = info.user?.user?.accountId {
            if let event = viewModel.onlineStatusDic[accountId] {
              if event.value == NIMSubscribeEventOnlineValue.login.rawValue {
                c.avatarImageView.alpha = 1.0
              }
            }
          }
        } else {
          c.avatarImageView.alpha = 1.0
        }
      }
      return configCell(info: info, c, indexPath)
    }
    return cell
  }
}

extension ContactViewController {
  override open func initSystemNav() {
    super.initSystemNav()
    let addItem = UIBarButtonItem(
      image: NEKitContactConfig.shared.ui.titleBarRightRes ?? UIImage.ne_imageNamed(name: "add"),
      style: .plain,
      target: self,
      action: #selector(goToFindFriend)
    )
    addItem.tintColor = UIColor(hexString: "333333")
    let searchItem = UIBarButtonItem(
      image: NEKitContactConfig.shared.ui.titleBarRight2Res ?? UIImage.ne_imageNamed(name: "contact_search"),
      style: .plain,
      target: self,
      action: #selector(searchContact)
    )
    searchItem.imageInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
    searchItem.tintColor = UIColor(hexString: "333333")

    navigationItem.rightBarButtonItems = [addItem, searchItem]
    if !NEKitContactConfig.shared.ui.showTitleBarRight2Icon {
      navigationItem.rightBarButtonItems = [addItem]
      navigationView.searchBtn.isHidden = true
    }
    if !NEKitContactConfig.shared.ui.showTitleBarRightIcon {
      navigationItem.rightBarButtonItems = [searchItem]
      navigationView.addBtn.isHidden = true
    }

    let brandBarBtn = UIButton()
    brandBarBtn.setTitle(NEKitContactConfig.shared.ui.title ?? localizable("contact"), for: .normal)
    brandBarBtn.setTitleColor(NEKitContactConfig.shared.ui.titleColor ?? UIColor.black, for: .normal)
    brandBarBtn.titleLabel?.font = NEConstant.textFont("PingFangSC-Medium", 20)
    let brandBtn = UIBarButtonItem(customView: brandBarBtn)
    navigationItem.leftBarButtonItem = brandBtn

    navigationView.brandBtn.setImage(nil, for: .normal)
    navigationView.brandBtn.setTitle(NEKitContactConfig.shared.ui.title ?? localizable("contact"), for: .normal)
    navigationView.brandBtn.setTitleColor(NEKitContactConfig.shared.ui.titleColor ?? UIColor.black, for: .normal)
    navigationView.brandBtn.titleEdgeInsets = UIEdgeInsets.zero
  }
}
