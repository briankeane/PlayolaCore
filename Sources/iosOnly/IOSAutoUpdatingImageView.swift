//
//  IOSAutoUpdatingImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

public class AutoUpdatingImageView: UIImageView {
    var placeholderImage:UIImage?
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    /// THIS IS MEANT TO BE OVERRIDDEN BY SUBCLASSES
    func commonInit()
    {

    }
    
    func getPlaceholderImage() -> UIImage
    {
        if let userSuppliedPlaceholderImage = self.placeholderImage
        {
            return userSuppliedPlaceholderImage
        }
        return UIImage.make(name: "emptyAlbum")!
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
