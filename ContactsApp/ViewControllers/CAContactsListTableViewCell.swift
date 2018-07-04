//
//  CAContactsListTableViewCell.swift
//  ContactsApp
//
//  Created by Lavanya on 02/07/18.
//  Copyright © 2018 Lavanya. All rights reserved.
//

import UIKit

class CAContactsListTableViewCell: UITableViewCell {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contactImage.layer.cornerRadius = contactImage.frame.size.height / 2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        self.contactImage.image = nil
    }
}
