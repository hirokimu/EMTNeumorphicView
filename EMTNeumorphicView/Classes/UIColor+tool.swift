//
//  UIColor+tool.swift
//
//  Created by Hironobu Kimura on 2020/01/20.
//  Copyright © 2020 Emotionale. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(RGB: Int) {
        var rgb = RGB
        rgb = rgb > 0xffffff ? 0xffffff : rgb
        let r = CGFloat(rgb >> 16) / 255.0
        let g = CGFloat(rgb >> 8 & 0x00ff) / 255.0
        let b = CGFloat(rgb & 0x0000ff) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    public func getTransformedColor(saturation: CGFloat, brightness: CGFloat) -> UIColor {
        var hsb = getHSBColor()
        hsb.s *= saturation
        hsb.b *= brightness
        if hsb.s > 1 { hsb.s = 1 }
        if hsb.b > 1 { hsb.b = 1 }
        return hsb.uiColor
    }
    private func getHSBColor() -> HSBColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return HSBColor(h: h, s: s, b: b, alpha: a)
    }
}

private struct HSBColor {
    var h: CGFloat
    var s: CGFloat
    var b: CGFloat
    var alpha: CGFloat
    init(h: CGFloat, s: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.h = h
        self.s = s
        self.b = b
        self.alpha = alpha
    }
    var uiColor: UIColor {
        get {
            return UIColor(hue: h, saturation: s, brightness: b, alpha: alpha)
        }
    }
}

