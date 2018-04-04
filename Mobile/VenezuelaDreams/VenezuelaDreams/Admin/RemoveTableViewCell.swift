//
//  RemoveTableViewCell.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 4/2/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import UIKit

class RemoveTableViewCell: UITableViewCell {

    @IBOutlet weak var nameCell: UILabel!
    @IBOutlet weak var pictureCell: UIImageView!
    @IBOutlet weak var dateCell: UILabel!
    var child_id = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
