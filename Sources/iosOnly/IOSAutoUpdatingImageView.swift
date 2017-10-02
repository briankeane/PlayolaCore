//
//  IOSAutoUpdatingImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

public class AutoUpdatingImageView: UIImageView {
    public var placeholderImage:UIImage?
    public var notPlayingImage:UIImage?
    public var withGradient:Bool = true
    
    private var _gradient:CAGradientLayer?
    
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
        if (self.withGradient)
        {
            self.addGradientLayer()
        }
    }
    
    func getPlaceholderImage() -> UIImage
    {
        if let userSuppliedPlaceholderImage = self.placeholderImage
        {
            return userSuppliedPlaceholderImage
        }
        return UIImage.makePlayolaImage(name: "emptyAlbum")!
    }
    
    func getNotPlayingImage() -> UIImage
    {
        if let userSuppliedNotPlayingImage = self.notPlayingImage
        {
            return  userSuppliedNotPlayingImage
        }
        return UIImage.makePlayolaImage(name: "emptyStation")!
    }
    
    
    func addGradientLayer()
    {
        if (self._gradient == nil)
        {
            let gradient = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.locations = [0.6]
            self.layer.addSublayer(gradient)
            self._gradient = gradient
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
