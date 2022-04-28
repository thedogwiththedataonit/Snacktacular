//
//  SnackUserTableViewCell.swift
//  Snacktacular
//
//  Created by Thomas Park on 4/25/22.
//

import UIKit
private let dateFormatter: DateFormatter = {

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class SnackUserTableViewCell: UITableViewCell {

    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userSinceLabel: UILabel!
    @IBOutlet weak var userimageView: UIImageView!
    
    var snackUser: SnackUser! {
        
        didSet {
            displayNameLabel.text = snackUser.displayName
            emailLabel.text = snackUser.email
            userSinceLabel.text = "\(dateFormatter.string(from: snackUser.userSince))"
            
            userimageView.layer.cornerRadius = self.userimageView.frame.size.width /2
            userimageView.clipsToBounds = true
            
            
            guard let url = URL(string: snackUser.photoURL) else {
                userimageView.image = UIImage(systemName: "person.crop.circle")
                return
            }
            userimageView.sd_imageTransition = .fade
            userimageView.sd_imageTransition?.duration = 0.1
            userimageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
    }
}
