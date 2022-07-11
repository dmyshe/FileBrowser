//
//  FileCell.swift
//  FileBrowser
//
//  Created by Дмитро  on 20.06.2022.
//

import Foundation
import UIKit

final class ItemCell: UICollectionViewCell {
    //MARK: - Identifier
    static let identifier = "ItemCell"
    
    //MARK: - IBOutlets
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    
    //MARK: - Methods
    public func configure(with model: Item) {
        fileName.text = model.name
        iconImageView.image = model.type == .f ? AppImages.systemDocImage : AppImages.systemFolderImage
    }
}
