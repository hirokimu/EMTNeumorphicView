//
//  EMTNeumorphicLayer.swift
//  EMTNeumorphicView
//
//  Created by Hironobu Kimura on 2020/01/20.
//  Copyright © 2020 Emotionale. All rights reserved.
//

import UIKit

public protocol EMTNeumorphicElementProtocol : UIView {
    var neumorphicLayer: EMTNeumorphicLayer? { get }
}

public enum EMTNeumorphicLayerCornerType: Int {
    case all,
    topRow,
    middleRow,
    bottomRow
}

public enum EMTNeumorphicLayerDepthType: Int {
    case concave,
    convex
}

fileprivate struct EMTNeumorphicLayerProps {
    var brightness: CGFloat = 1.15
    var elementColor: CGColor?
    var elementBackgroundColor: CGColor = UIColor.white.cgColor
    var depthType: EMTNeumorphicLayerDepthType = .convex
    var cornerType: EMTNeumorphicLayerCornerType = .all
    var elementDepth: CGFloat = 100 * 0.143 / 2
    var edged: Bool = false
    var cornerRadius: CGFloat = 0
    static func == (lhs: EMTNeumorphicLayerProps, rhs: EMTNeumorphicLayerProps) -> Bool {
        return lhs.brightness == rhs.brightness &&
            lhs.elementColor === rhs.elementColor &&
            lhs.elementBackgroundColor === rhs.elementBackgroundColor &&
            lhs.depthType == rhs.depthType &&
            lhs.cornerType == rhs.cornerType &&
            lhs.elementDepth == rhs.elementDepth &&
            lhs.edged == rhs.edged &&
            lhs.cornerRadius == rhs.cornerRadius
    }
}

/**
 `EMTNeumorphicLayer` is a subclsss of CALayer which provides "neumorphic" effect.
 Recommends to use EMTNeumorphicView / EMTNeumorphicButotn /  EMTNeumorphicCell and access neumorphicLayer of these.
 */
public class EMTNeumorphicLayer: CALayer {
    
    // MARK: Properties

    private var props: EMTNeumorphicLayerProps?
    
    /// This value multiplies the brightness of light shadow. Default is 2.
    public var brightness: CGFloat = 2 {
        didSet {
            if oldValue != brightness {
                setNeedsDisplay()
            }
        }
    }

    /// Optional. if it is nil (default), elementBackgroundColor will be used as element color.
    public var elementColor: CGColor? {
        didSet {
            if oldValue !== elementColor {
                setNeedsDisplay()
            }
        }
    }
    private var elementSelectedColor: CGColor?
    
    /// It will be used as base color for light/shadow. If elementColor is nil, elementBackgroundColor will be used as elementColor.
    public var elementBackgroundColor: CGColor = UIColor.white.cgColor {
        didSet {
            if oldValue !== elementBackgroundColor {
                setNeedsDisplay()
            }
        }
    }
    public var depthType: EMTNeumorphicLayerDepthType = .convex {
        didSet {
            if oldValue != depthType {
                setNeedsDisplay()
            }
        }
    }
    
    /// ".all" is for buttons. ".topRowm" ".middleRow" ".bottomRow" is for table cells.
    public var cornerType: EMTNeumorphicLayerCornerType = .all {
        didSet {
            if oldValue != cornerType {
                setNeedsDisplay()
            }
        }
    }
    
    /// Default is 7.15 px
    public var elementDepth: CGFloat = 100 * 0.143 / 2 {
        didSet {
            if oldValue != elementDepth {
                setNeedsDisplay()
            }
        }
    }
    
    /// Adding a very thin border on the edge of the element.
    public var edged: Bool = false {
        didSet {
            if oldValue != edged {
                setNeedsDisplay()
            }
        }
    }

    /// If set to true, show element highlight color. Animated.
    public var selected: Bool {
        get {
            return _selected
        }
        set {
            _selected = newValue
            let color = elementColor ?? elementBackgroundColor
            elementSelectedColor = UIColor(cgColor: color).getTransformedColor(saturation: 1, brightness: 0.9).cgColor
            colorLayer?.backgroundColor = _selected ? elementSelectedColor : color
        }
    }
    private var _selected: Bool = false
    
    private var colorLayer: CALayer?
    private var shadowLayer: EMTShadowLayer?
    private var lightLayer: EMTShadowLayer?
    private var edgeLayer: EMTEdgeLayer?
    private var darkSideColor: CGColor = UIColor.black.cgColor
    private var lightSideColor: CGColor = UIColor.white.cgColor

    
    // MARK: Build Layers
    
    public override func display() {
        super.display()
        update()
    }
    
    public func update() {
        // check property update
        let isBoundsUpdated: Bool = colorLayer?.bounds != bounds
        var currentProps = EMTNeumorphicLayerProps()
        currentProps.cornerType = cornerType
        currentProps.depthType = depthType
        currentProps.edged = edged
        currentProps.brightness = brightness
        currentProps.elementColor = elementColor
        currentProps.elementBackgroundColor = elementBackgroundColor
        currentProps.elementDepth = elementDepth
        currentProps.cornerRadius = cornerRadius
        let isPropsNotChanged = props == nil ? true : currentProps == props!
        if !isBoundsUpdated && isPropsNotChanged {
            return
        }
        props = currentProps

        // generate shadow color
        let color = elementColor ?? elementBackgroundColor
        lightSideColor = UIColor(cgColor: elementBackgroundColor).getTransformedColor(saturation: 0.5, brightness: brightness).cgColor
        darkSideColor = UIColor(cgColor: elementBackgroundColor).getTransformedColor(saturation: 0.1, brightness: 0).cgColor
        lightSideColor = UIColor.white.cgColor
        // add sublayers
        if colorLayer == nil {
            colorLayer = CALayer()
            colorLayer?.cornerCurve = .continuous
            shadowLayer = EMTShadowLayer()
            lightLayer = EMTShadowLayer()
            edgeLayer = EMTEdgeLayer()
            insertSublayer(edgeLayer!, at: 0)
            insertSublayer(colorLayer!, at: 0)
            insertSublayer(lightLayer!, at: 0)
            insertSublayer(shadowLayer!, at: 0)
        }
        colorLayer?.frame = bounds
        colorLayer?.backgroundColor = _selected ? elementSelectedColor : color
        if depthType == .convex {
            masksToBounds = false
            colorLayer?.removeFromSuperlayer()
            insertSublayer(colorLayer!, at: 2)
            colorLayer?.masksToBounds = true
            shadowLayer?.masksToBounds = false
            lightLayer?.masksToBounds = false
            edgeLayer?.masksToBounds = false
        }
        else {
            masksToBounds = true
            colorLayer?.removeFromSuperlayer()
            insertSublayer(colorLayer!, at: 0)
            colorLayer?.masksToBounds = true
            shadowLayer?.masksToBounds = true
            lightLayer?.masksToBounds = true
            edgeLayer?.masksToBounds = true
        }
        
        // initialize sublayers
        shadowLayer?.initialize(bounds: bounds, mode: .darkSide, props: props!, color: darkSideColor)
        lightLayer?.initialize(bounds: bounds, mode: .lightSide, props: props!, color: lightSideColor)
        //lightLayer?.initialize(bounds: bounds, mode: .lightSide, props: props!, color: UIColor.red.cgColor)
        if currentProps.edged {
            edgeLayer?.initialize(bounds: bounds, props: props!, color: lightSideColor)
        }
        else {
            edgeLayer?.reset()
        }
                
        // set corners
        switch cornerType {
        case .all:
            if depthType == .convex {
                colorLayer?.cornerRadius = cornerRadius
            }
        case .topRow:
            maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .middleRow:
            maskedCorners = []
        case .bottomRow:
            maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
}

fileprivate enum EMTShadowLayerMode: Int {
    case lightSide,
    darkSide
}

fileprivate class EMTShadowLayerBase: CALayer {
    static let corners: [EMTNeumorphicLayerCornerType: UIRectCorner] = [.all: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                                                        .topRow: [.topLeft, .topRight],
                                                                        .middleRow: [],
                                                                        .bottomRow: [.bottomLeft, .bottomRight]
    ]
    func setCorner(props: EMTNeumorphicLayerProps) {
        switch props.cornerType {
        case .all:
            cornerRadius = props.cornerRadius
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .topRow:
            cornerRadius = props.cornerRadius
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .middleRow:
            cornerRadius = 0
            maskedCorners = []
        case .bottomRow:
            cornerRadius = props.cornerRadius
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}

fileprivate class EMTShadowLayer: EMTShadowLayerBase {
 
    private let expandWidth: CGFloat = 1
    private var lightLayer: CALayer?
    
    func initialize(bounds: CGRect, mode: EMTShadowLayerMode, props: EMTNeumorphicLayerProps, color: CGColor) {
        cornerCurve = .continuous
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
        if props.depthType == .convex {
            applyOuterShadow(bounds: bounds, mode: mode, props: props, color: color)
        }
        else { // .concave
            applyInnerShadow(bounds: bounds, mode: mode, props: props, color: color)
        }
    }
    
    func applyOuterShadow(bounds: CGRect, mode: EMTShadowLayerMode, props: EMTNeumorphicLayerProps, color: CGColor) {
        
        lightLayer?.removeFromSuperlayer()
        lightLayer = nil
        
        frame = bounds
        cornerRadius = 0
        maskedCorners = []
        masksToBounds = false
        mask = nil
        
        // prepare shadow parameters
        let shadowRadius = props.elementDepth
        let offsetWidth: CGFloat = shadowRadius / 2
        let cornerRadii: CGSize = CGSize(width: props.cornerRadius, height: props.cornerRadius)
    
        var shadowX: CGFloat = 0
        var shadowY: CGFloat = 0
        if mode == .lightSide {
            shadowY = -offsetWidth
            shadowX = -offsetWidth
        }
        else {
            shadowY = offsetWidth
            shadowX = offsetWidth
        }
        
        // add shadow
        let shadowBounds = bounds
        let path: UIBezierPath = UIBezierPath(roundedRect: shadowBounds.insetBy(dx: offsetWidth, dy: offsetWidth),
                                              byRoundingCorners: EMTShadowLayer.corners[.all]!,
                                              cornerRadii: cornerRadii)
        shadowPath = path.cgPath
        shadowColor = color
        shadowOffset = CGSize(width: shadowX, height: shadowY)
        shadowOpacity = mode == .lightSide ? 1 : 0.3
        self.shadowRadius = shadowRadius
    }
    
    func applyInnerShadow(bounds: CGRect, mode: EMTShadowLayerMode, props: EMTNeumorphicLayerProps, color: CGColor) {
        let width = bounds.size.width
        let height = bounds.size.height
        
        frame = bounds
        
        // prepare shadow parameters
        let shadowRadius = mode == .lightSide ? props.elementDepth / 2 : props.elementDepth / 2
        
        let cornerRadii: CGSize = CGSize(width: props.cornerRadius, height: props.cornerRadius)
        let cornerRadiusInner = props.cornerRadius - (sqrt(2) * expandWidth)
        let cornerRadiiInner: CGSize = CGSize(width: cornerRadiusInner, height: cornerRadiusInner)

        var shadowX: CGFloat = 0
        var shadowY: CGFloat = 0
        var shadowWidth: CGFloat = width
        var shadowHeight: CGFloat = height

        setCorner(props: props)
        let corners = EMTShadowLayer.corners[props.cornerType]!
        
        switch props.cornerType {
        case .all:
            break
        case .topRow:
            shadowHeight += shadowRadius * 4
        case .middleRow:
            if mode == .lightSide {
                shadowWidth += shadowRadius * 2 + 0.5
                shadowHeight += shadowRadius * 6
                shadowY = -(shadowRadius * 3)
                shadowX = -(shadowRadius * 2)
            }
            else {
                shadowWidth += shadowRadius * 2
                shadowHeight += shadowRadius * 6
                shadowY -= (shadowRadius * 3)
            }
        case .bottomRow:
            shadowHeight += shadowRadius * 4
            shadowY = -shadowRadius * 4
        }

        // add shadow
        var shadowBounds = CGRect(x: 0, y: 0, width: shadowWidth, height: shadowHeight)
        if mode == .darkSide { shadowBounds = shadowBounds.insetBy(dx: -1, dy: -1) }
        var path: UIBezierPath
        var innerPath: UIBezierPath
        
        if props.cornerType == .middleRow {
            path = UIBezierPath(rect: shadowBounds)
            innerPath = UIBezierPath(rect: shadowBounds.insetBy(dx: expandWidth, dy: expandWidth)).reversing()
        }
        else {
            path = UIBezierPath(roundedRect:shadowBounds,
                                byRoundingCorners: corners,
                                cornerRadii: cornerRadii)
            innerPath = UIBezierPath(roundedRect: shadowBounds.insetBy(dx: expandWidth, dy: expandWidth),
                                     byRoundingCorners: corners,
                                     cornerRadii: cornerRadiiInner).reversing()
        }
        path.append(innerPath)

        shadowPath = path.cgPath
        masksToBounds = true
        shadowColor = color
        shadowOffset = CGSize(width: shadowX, height: shadowY)
        shadowOpacity = 1
        self.shadowRadius = shadowRadius
        
        if mode == .lightSide {
            if lightLayer == nil {
                lightLayer = CALayer()
                addSublayer(lightLayer!)
            }
            lightLayer?.frame = bounds
            lightLayer?.shadowPath = path.cgPath
            lightLayer?.masksToBounds = true
            lightLayer?.shadowColor = shadowColor
            lightLayer?.shadowOffset = CGSize(width: shadowX, height: shadowY)
            lightLayer?.shadowOpacity = 1
            lightLayer?.shadowRadius = shadowRadius
            lightLayer?.shouldRasterize = true
        }
        
        // add mask to shadow
        if props.cornerType == .middleRow {
            mask = nil
        }
        else {
            let maskLayer = EMTGradientMaskLayer()
            maskLayer.frame = bounds
            maskLayer.cornerType = props.cornerType
            maskLayer.shadowLayerMode = mode
            maskLayer.shadowCornerRadius = props.cornerRadius
            mask = maskLayer
        }
    }
}

fileprivate class EMTEdgeLayer: EMTShadowLayerBase {
    func initialize(bounds: CGRect, props: EMTNeumorphicLayerProps, color: CGColor) {
        
        setCorner(props: props)
        let corners = EMTEdgeLayer.corners[props.cornerType]!
        
        cornerCurve = .continuous
        shouldRasterize = true
        frame = bounds
        
        var shadowY: CGFloat = 0
        var path: UIBezierPath
        var innerPath: UIBezierPath
        
        var edgeBounds = bounds
        let cornerRadii: CGSize = CGSize(width: props.cornerRadius, height: props.cornerRadius)
        let cornerRadiusEdge = props.cornerRadius - (sqrt(2) * 0.75)
        let cornerRadiiEdge: CGSize = CGSize(width: cornerRadiusEdge, height: cornerRadiusEdge)
        
        if props.depthType == .convex {
            path = UIBezierPath(roundedRect: edgeBounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
            let innerPath = UIBezierPath(roundedRect: edgeBounds.insetBy(dx: 0.75, dy: 0.75),
                                    byRoundingCorners: corners, cornerRadii: cornerRadiiEdge).reversing()
            path.append(innerPath)
            shadowPath = path.cgPath
            shadowColor = color
            shadowOffset = CGSize.zero
            shadowOpacity = 0.1
            shadowRadius = 0
        }
        else {
            // shadow size and y position
            if props.depthType == .concave {
                switch props.cornerType {
                case .all:
                    break
                case .topRow:
                    edgeBounds.size.height += 2
                case .middleRow:
                    shadowY = -5
                    edgeBounds.size.height += 10
                case .bottomRow:
                    shadowY = -2
                    edgeBounds.size.height += 2
                }
            }
            // shadow path
            if props.cornerType == .middleRow {
                path = UIBezierPath(rect: edgeBounds)
                innerPath = UIBezierPath(rect: edgeBounds.insetBy(dx: 0.75, dy: 0.75)).reversing()
            }
            else {
                path = UIBezierPath(roundedRect: edgeBounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
                innerPath = UIBezierPath(roundedRect: edgeBounds.insetBy(dx: 0.75, dy: 0.75),
                                        byRoundingCorners: corners, cornerRadii: cornerRadiiEdge).reversing()
            }
            
            path.append(innerPath)
            shadowPath = path.cgPath
            shadowColor = color
            shadowOffset = CGSize(width: 0, height: shadowY)
            shadowOpacity = 0.1
            shadowRadius = 0
        }
    }
    func reset() {
        shadowPath = nil
        shadowOffset = CGSize.zero
        shadowOpacity = 0
        frame = CGRect()
    }
}

fileprivate class EMTGradientMaskLayer: CALayer {
    required override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    required override init(layer: Any) {
        super.init(layer: layer)
    }
 
    var cornerType: EMTNeumorphicLayerCornerType = .all
    var shadowLayerMode: EMTShadowLayerMode = .lightSide
    var shadowCornerRadius: CGFloat = 0

    private func getTopRightCornerRect(size: CGSize, radius: CGFloat) -> CGRect {
        return CGRect(x: size.width - radius, y: 0, width: radius, height: radius)
    }
    private func getBottomLeftCornerRect(size: CGSize, radius: CGFloat) -> CGRect {
        return CGRect(x: 0, y: size.height - radius, width: radius, height: radius)
    }

    override func draw(in ctx: CGContext) {
        let rectTR = getTopRightCornerRect(size: frame.size, radius: shadowCornerRadius)
        let rectTR_BR = CGPoint(x: rectTR.origin.x + shadowCornerRadius, y: rectTR.origin.y + shadowCornerRadius)
        let rectBL = getBottomLeftCornerRect(size: frame.size, radius: shadowCornerRadius)
        let rectBL_BR = CGPoint(x: rectBL.origin.x + shadowCornerRadius, y: rectBL.origin.y + shadowCornerRadius)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: [UIColor.black.cgColor, UIColor.clear.cgColor] as CFArray,
                                        locations: [0, 1]) else { return }
        if cornerType == .all {
            if shadowLayerMode == .lightSide {
                if frame.size.width > shadowCornerRadius * 2 && frame.size.height > shadowCornerRadius * 2 {
                    ctx.setFillColor(UIColor.black.cgColor)
                    ctx.fill(CGRect(x: shadowCornerRadius,
                                    y: shadowCornerRadius,
                                    width: frame.size.width - shadowCornerRadius,
                                    height: frame.size.height - shadowCornerRadius)
                    )
                }
                ctx.saveGState()
                ctx.addRect(rectTR)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectTR_BR, end: rectTR.origin, options: [])
                ctx.restoreGState()
                ctx.saveGState()
                ctx.addRect(rectBL)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectBL_BR, end: rectBL.origin, options: [])
                ctx.restoreGState()
            }
            else {
                if frame.size.width > shadowCornerRadius * 2 && frame.size.height > shadowCornerRadius * 2 {
                ctx.setFillColor(UIColor.black.cgColor)
                    ctx.fill(CGRect(x: 0,
                                    y: 0,
                                    width: frame.size.width - shadowCornerRadius,
                                    height: frame.size.height - shadowCornerRadius)
                    )
                }
                ctx.saveGState()
                ctx.addRect(rectTR)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectTR.origin, end: rectTR_BR, options: [])
                ctx.restoreGState()
                ctx.saveGState()
                ctx.addRect(rectBL)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectBL.origin, end: rectBL_BR, options: [])
                ctx.restoreGState()
            }
        }
        else if cornerType == .topRow {
            if shadowLayerMode == .lightSide {
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(CGRect(x: frame.size.width - shadowCornerRadius,
                                y: shadowCornerRadius,
                                width: frame.size.width,
                                height: frame.size.height - shadowCornerRadius)
                )
                ctx.saveGState()
                ctx.addRect(rectTR)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectTR_BR, end: rectTR.origin, options: [])
                ctx.restoreGState()
            }
            else {
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(CGRect(x: 0,
                                y: 0,
                                width: frame.size.width - shadowCornerRadius,
                                height: frame.size.height)
                )
                ctx.saveGState()
                ctx.addRect(rectTR)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectTR.origin, end: rectTR_BR, options: [])
                ctx.restoreGState()
            }
        }
        else if cornerType == .bottomRow {
            if shadowLayerMode == .lightSide {
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(CGRect(x: shadowCornerRadius,
                                y: 0,
                                width: frame.size.width - shadowCornerRadius,
                                height: frame.size.height)
                )
                ctx.saveGState()
                ctx.addRect(rectBL)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectBL_BR, end: rectBL.origin, options: [])
                ctx.restoreGState()
            }
            else {
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(CGRect(x: 0,
                                y: 0,
                                width: shadowCornerRadius,
                                height: frame.size.height - shadowCornerRadius)
                )
                ctx.saveGState()
                ctx.addRect(rectBL)
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: rectBL.origin, end: rectBL_BR, options: [])
                ctx.restoreGState()
            }
        }
    }
}
