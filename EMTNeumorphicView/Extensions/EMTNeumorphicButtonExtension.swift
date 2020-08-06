//
//  EMTNeumorphicButtonExtension.swift
//  IBInspectable properties for EMTNeumorphicButton
//
//  Created by vividcode on 8/7/20.
//  Copyright © 2020 vividcode. All rights reserved.
//

import Foundation
import UIKit

extension EMTNeumorphicButton
{
    @IBInspectable
    var depthType: Int {
        get {
            return self.neumorphicLayer?.depthType.rawValue ?? EMTNeumorphicLayerDepthType.convex.rawValue
        }
        set {
            if let dType = EMTNeumorphicLayerDepthType(rawValue: newValue)
            {
                self.neumorphicLayer?.depthType = dType
            }
            else
            {
                self.neumorphicLayer?.depthType = .convex
            }
        }
    }
    
    @IBInspectable
    var edged : Bool {
        get {
            return self.neumorphicLayer?.edged ?? false
        }
        set {
            self.neumorphicLayer?.edged = newValue
        }
    }
    
    @IBInspectable
    var layerElementColor : UIColor
    {
        get {
            if let eB = self.neumorphicLayer?.elementBackgroundColor
            {
                return UIColor(cgColor: eB)
            }
            return .white
        }
        set {
            self.neumorphicLayer?.elementBackgroundColor = newValue.cgColor
        }
    }
}
