//
//  PreviewCell.swift
//  Test_Interface
//
//  Created by Pasquale Nardiello on 20/07/21.
//

import UIKit

class PreviewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with preview: Preview) {
        titleLabel.text = preview.displayName
        subtitleLabel.text = preview.previewCategory
        
        if let thumb = preview.thumbnail {
            thumbnailImageView.image = thumb
        }
    }

}
