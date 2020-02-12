//
//  UsersListTableViewCell.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 09.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class UsersListTableViewCell: UITableViewCell {
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var isAdminSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
