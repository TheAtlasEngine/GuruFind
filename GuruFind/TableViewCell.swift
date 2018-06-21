//
//  TableViewCell.swift
//  GuruFind
//
//  Created by Kosuke Nishimura on 2018/06/17.
//  Copyright © 2018年 Kosuke.Nishimura. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var restNameLabel: UILabel!
    @IBOutlet weak var restAccessLabel: UILabel!
    @IBOutlet weak var restImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
