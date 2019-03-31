//
//  CustomTableViewCell.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

  @IBOutlet weak var dateLabel: UILabel!

  @IBOutlet weak var valueLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
