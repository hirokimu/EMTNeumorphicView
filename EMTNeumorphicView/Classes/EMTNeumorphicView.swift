//
//  EMTNeumorphicView.swift
//  EMTNeumorphicView
//
//  Created by Hironobu Kimura on 2020/01/20.
//  Copyright © 2020 Emotionale. All rights reserved.
//

import UIKit

/**
 `EMTNeumorphicView` is a subclass of UIView and it provides some Neumorphism style design.
 Access neumorphicLayer. Change effects via its properties.
 */
public class EMTNeumorphicView: UIView, EMTNeumorphicElementProtocol {
    /// Change effects via its properties.
    public var neumorphicLayer: EMTNeumorphicLayer? {
        return layer as? EMTNeumorphicLayer
    }
    public override class var layerClass: AnyClass {
        return EMTNeumorphicLayer.self
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        neumorphicLayer?.update()
    }
}

/**
 `EMTNeumorphicButton` is a subclass of UIView and it provides some Neumorphism style design.
 Access neumorphicLayer. Change effects via its properties.
 */
public class EMTNeumorphicButton: UIButton, EMTNeumorphicElementProtocol {
    /// Change effects via its properties.
    public var neumorphicLayer: EMTNeumorphicLayer? {
        return layer as? EMTNeumorphicLayer
    }
    public override class var layerClass: AnyClass {
        return EMTNeumorphicLayer.self
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        neumorphicLayer?.update()
    }
    public override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                neumorphicLayer?.selected = isHighlighted
            }
        }
    }
    public override var isSelected: Bool {
        didSet {
            if oldValue != isSelected {
                neumorphicLayer?.depthType = isSelected ? .concave : .convex
            }
        }
    }
}

/**
 `EMTNeumorphicTableCell` is a subclass of UITableViewCell and it provides some Neumorphism style design.
 Access neumorphicLayer. Change effects via its properties.
 */
public class EMTNeumorphicTableCell: UITableViewCell, EMTNeumorphicElementProtocol {

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Change effects via its properties.
    public var neumorphicLayer: EMTNeumorphicLayer? {
        if bg == nil {
            bg = EMTNeumorphicView(frame: bounds)
            bg?.neumorphicLayer?.masterView = self
            selectedBackgroundView = UIView()
            layer.masksToBounds = true
            backgroundView = bg
        }
        return bg?.neumorphicLayer
    }
    private var bg: EMTNeumorphicView?
    public override func layoutSubviews() {
        super.layoutSubviews()
        neumorphicLayer?.update()
    }
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        neumorphicLayer?.selected = highlighted
    }
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        neumorphicLayer?.selected = selected
    }
    public func depthTypeUpdated(to type: EMTNeumorphicLayerDepthType) {
        if let l = bg?.neumorphicLayer {
            layer.masksToBounds = l.depthType == .concave
        }
    }
}
