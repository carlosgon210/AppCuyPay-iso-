//
//  MovimentoTableViewCell.swift
//  CUYPAY
//
//  Created by DAMII on 28/04/25.
//

import UIKit

class MovimentoTableViewCell: UITableViewCell {

    @IBOutlet weak var descripcionLable: UILabel!
    
    @IBOutlet weak var montoLable: UILabel!
    
    @IBOutlet weak var fechaLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
