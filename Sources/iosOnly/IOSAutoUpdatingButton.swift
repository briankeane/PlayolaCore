//
//  AutoUpdatingButton.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

public class AutoUpdatingButton: UIButton {
    var isPlayingImage:UIImage?
    var isStoppedImage:UIImage?
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    public func commonInit()
    {
        
    }
    
    public func setImage(image:UIImage?)
    {
        if let image = image
        {
            self.setImage(image, for: .normal)
        }
    }
    
    public func getTitle() -> String?
    {
        return self.titleLabel?.text
    }
    
    public func getIsPlayingImage() -> UIImage
    {
        if let isPlayingImage = self.isPlayingImage
        {
            return isPlayingImage
        }
        else
        {
            return UIImage.make(name: "playButtonStop")!
        }
    }
    
    public func getIsStoppedImage() -> UIImage
    {
        if let isPlayingImage = self.isPlayingImage
        {
            return isPlayingImage
        }
        else
        {
            return UIImage.make(name: "playButtonPlay")!
        }
    }
    
    public func setTitle(title:String)
    {
        self.setTitle(title, for: .normal)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
