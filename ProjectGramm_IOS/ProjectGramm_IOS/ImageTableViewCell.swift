

import UIKit


class ImageTableViewCell:UITableViewCell{
    
    var mainImage:UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(mainImage)
        mainImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
