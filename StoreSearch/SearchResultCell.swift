//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by 彭军涛 on 2019/3/27.
//  Copyright © 2019 彭军涛. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var atrworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectView = UIView(frame: CGRect.zero)
        selectView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectView
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Public Methods
    func configure(for result: SearchResult){
        nameLabel.text = result.name
        
        if result.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        }else{
            artistNameLabel.text = String(format: "%@(%@)", result.artistName,result.type)
        }
        
        atrworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = atrworkImageView.loadImage(url: smallURL)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
}
