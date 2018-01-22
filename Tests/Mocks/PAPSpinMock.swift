//
//  PAPSpinMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PAPSpinMock: PAPSpin
{
    // do not load player
    
    override func loadPlayer()
    {
        print("pretending to load player")
    }

}
