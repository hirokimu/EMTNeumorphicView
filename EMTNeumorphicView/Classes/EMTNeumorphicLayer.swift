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
    func depthTypeUpdated(to type: EMTNeumorphicLayerDepthType)
}

public extension EMTNeumorphicElementProtocol {
    func depthTypeUpdated(to type: EMTNeumorphicLayerDepthType) {
        //
    }
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
    var lightShadowOpacity: Float = 1
    var darkShadowOpacity: Float = 0.3
    var elementColor: CGColor?
    var elementBackgroundColor: CGColor = UIColor.white.cgColor
    var depthType: EMTNeumorphicLayerDepthType = .convex
    var cornerType: EMTNeumorphicLayerCornerType = .all
    var elementDepth: CGFloat = 5
    var edged: Bool = false
    var cornerRadius: CGFloat = 0
    static func == (lhs: EMTNeumorphicLayerProps, rhs: EMTNeumorphicLayerProps) -> Bool {
        return lhs.lightShadowOpacity == rhs.lightShadowOpacity &&
            lhs.darkShadowOpacity == rhs.darkShadowOpacity &&
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

    public weak var masterView: EMTNeumorphicElementProtocol?
    
    /// Default is 1.
    public var lightShadowOpacity: Float = 1 {
        didSet {
            if oldValue != lightShadowOpacity {
                setNeedsDisplay()
            }
        }
    }
    
    /// Default is 0.3.
    public var darkShadowOpacity: Float = 0.3 {
        didSet {
            if oldValue != darkShadowOpacity {
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
                masterView?.depthTypeUpdated(to: depthType)
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
    
    /// Default is 5.
    public var elementDepth: CGFloat = 5 {
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
        currentProps.lightShadowOpacity = lightShadowOpacity
        currentProps.darkShadowOpacity = darkShadowOpacity
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
        lightSideColor = UIColor.white.cgColor
        darkSideColor = UIColor(cgColor: elementBackgroundColor).getTransformedColor(saturation: 0.1, brightness: 0).cgColor
 
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

        if currentProps.edged {
            edgeLayer?.initialize(bounds: bounds, props: props!, color: lightSideColor)
        }
        else {
            edgeLayer?.reset()
        }
                
        // set corners and outer mask
        switch cornerType {
        case .all:
            if depthType == .convex {
                colorLayer?.cornerRadius = cornerRadius
            }
        case .topRow:
            maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            if depthType == .convex {
                colorLayer?.cornerRadius = cornerRadius
                colorLayer?.maskedCorners = maskedCorners
                applyOuterMask(bounds: bounds, props: props!)
            }
            else {
                mask = nil
            }
        case .middleRow:
            maskedCorners = []
            if depthType == .convex {
                applyOuterMask(bounds: bounds, props: props!)
            }
            else {
                mask = nil
            }
        case .bottomRow:
            maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            if depthType == .convex {
                colorLayer?.cornerRadius = cornerRadius
                colorLayer?.maskedCorners = maskedCorners
                applyOuterMask(bounds: bounds, props: props!)
            }
            else {
                mask = nil
            }
        }
    }

    private func applyOuterMask(bounds: CGRect, props: EMTNeumorphicLayerProps) {
        let shadowRadius = props.elementDepth
        let extendWidth = shadowRadius * 2
        var maskFrame = CGRect()
        switch props.cornerType {
        case .all:
            return
        case .topRow:
            maskFrame = CGRect(x: -extendWidth, y: -extendWidth, width: bounds.size.width + extendWidth * 2, height: bounds.size.height + extendWidth)
        case .middleRow:
            maskFrame = CGRect(x: -extendWidth, y: 0, width: bounds.size.width + extendWidth * 2, height: bounds.size.height)
        case .bottomRow:
            maskFrame = CGRect(x: -extendWidth, y: 0, width: bounds.size.width + extendWidth * 2, height: bounds.size.height + extendWidth)
        }
        let maskLayer = CALayer()
        maskLayer.frame = maskFrame
        maskLayer.backgroundColor = UIColor.white.cgColor
        mask = maskLayer
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
        
        let shadowCornerRadius = props.cornerType == .middleRow ? 0 : props.cornerRadius
        
        // prepare shadow parameters
        let shadowRadius = props.elementDepth
        let offsetWidth: CGFloat = shadowRadius / 2
        let cornerRadii: CGSize = props.cornerRadius <= 0 ? CGSize.zero : CGSize(width: shadowCornerRadius - offsetWidth, height: shadowCornerRadius - offsetWidth)
    
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
   
        setCorner(props: props)
        let corners = EMTShadowLayer.corners[props.cornerType]!
   
        let extendHeight = max(props.cornerRadius, shadowCornerRadius)
        
        // add shadow
        var shadowBounds = bounds
        switch props.cornerType {
        case .all:
            break
        case .topRow:
            shadowBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height + extendHeight)
        case .middleRow:
            shadowY = 0
            shadowBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - extendHeight, width: bounds.size.width, height: bounds.size.height + extendHeight * 2)
        case .bottomRow:
            shadowBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - extendHeight, width: bounds.size.width, height: bounds.size.height + extendHeight)
        }

        let path: UIBezierPath = UIBezierPath(roundedRect: shadowBounds.insetBy(dx: offsetWidth, dy: offsetWidth),
                                              byRoundingCorners: corners,
                                              cornerRadii: cornerRadii)
        shadowPath = path.cgPath
        shadowColor = color
        shadowOffset = CGSize(width: shadowX, height: shadowY)
        shadowOpacity = mode == .lightSide ? props.lightShadowOpacity : props.darkShadowOpacity
        self.shadowRadius = shadowRadius
    }

    func applyInnerShadow(bounds: CGRect, mode: EMTShadowLayerMode, props: EMTNeumorphicLayerProps, color: CGColor) {
        let width = bounds.size.width
        let height = bounds.size.height
        
        frame = bounds
        
        // prepare shadow parameters
        let shadowRadius = props.elementDepth * 0.75

        let gap: CGFloat = 1

        let cornerRadii: CGSize = CGSize(width: props.cornerRadius + gap, height: props.cornerRadius + gap)
        let cornerRadiusInner = props.cornerRadius - gap
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
                shadowWidth += shadowRadius * 3
                shadowHeight += shadowRadius * 6
                shadowY = -(shadowRadius * 3)
                shadowX = -(shadowRadius * 3)
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
        let shadowBounds = CGRect(x: 0, y: 0, width: shadowWidth, height: shadowHeight)
        var path: UIBezierPath
        var innerPath: UIBezierPath
        
        if props.cornerType == .middleRow {
            path = UIBezierPath(rect: shadowBounds.insetBy(dx: -gap, dy: -gap))
            innerPath = UIBezierPath(rect: shadowBounds.insetBy(dx: gap, dy: gap)).reversing()
        }
        else {
            path = UIBezierPath(roundedRect:shadowBounds.insetBy(dx: -gap, dy: -gap),
                                byRoundingCorners: corners,
                                cornerRadii: cornerRadii)
            innerPath = UIBezierPath(roundedRect: shadowBounds.insetBy(dx: gap, dy: gap),
                                     byRoundingCorners: corners,
                                     cornerRadii: cornerRadiiInner).reversing()
        }
        path.append(innerPath)

        shadowPath = path.cgPath
        masksToBounds = true
        shadowColor = color
        shadowOffset = CGSize(width: shadowX, height: shadowY)
        shadowOpacity = mode == .lightSide ? props.lightShadowOpacity : props.darkShadowOpacity
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
            lightLayer?.shadowOpacity = props.lightShadowOpacity
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
        let edgeWidth: CGFloat = 0.75
        
        var edgeBounds = bounds
        let cornerRadii: CGSize = CGSize(width: props.cornerRadius, height: props.cornerRadius)
        let cornerRadiusEdge = props.cornerRadius - edgeWidth
        let cornerRadiiEdge: CGSize = CGSize(width: cornerRadiusEdge, height: cornerRadiusEdge)
        
        if props.depthType == .convex {
            
            switch props.cornerType {
            case .all:
                break
            case .topRow:
                edgeBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height + 2)
            case .middleRow:
                edgeBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - 2, width: bounds.size.width, height: bounds.size.height + 4)
            case .bottomRow:
                edgeBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - 2, width: bounds.size.width, height: bounds.size.height + 2)
            }
            
            path = UIBezierPath(roundedRect: edgeBounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
            let innerPath = UIBezierPath(roundedRect: edgeBounds.insetBy(dx: edgeWidth, dy: edgeWidth),
                                    byRoundingCorners: corners, cornerRadii: cornerRadiiEdge).reversing()
            path.append(innerPath)
            shadowPath = path.cgPath
            shadowColor = color
            shadowOffset = CGSize.zero
            shadowOpacity = min(props.lightShadowOpacity * 1.5, 1)
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
                innerPath = UIBezierPath(rect: edgeBounds.insetBy(dx: edgeWidth, dy: edgeWidth)).reversing()
            }
            else {
                path = UIBezierPath(roundedRect: edgeBounds, byRoundingCorners: corners, cornerRadii: cornerRadii)
                innerPath = UIBezierPath(roundedRect: edgeBounds.insetBy(dx: edgeWidth, dy: edgeWidth),
                                        byRoundingCorners: corners, cornerRadii: cornerRadiiEdge).reversing()
            }
            
            path.append(innerPath)
            shadowPath = path.cgPath
            shadowColor = color
            shadowOffset = CGSize(width: 0, height: shadowY)
            shadowOpacity = min(props.lightShadowOpacity * 1.5, 1)
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
        let rectTR_BR = CGPoint(x: rectTR.maxX, y: rectTR.maxY)
        let rectBL = getBottomLeftCornerRect(size: frame.size, radius: shadowCornerRadius)
        let rectBL_BR = CGPoint(x: rectBL.maxX, y: rectBL.maxY)
        
        let color = UIColor.black.cgColor
        
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: [color, UIColor.clear.cgColor] as CFArray,
                                        locations: [0, 1]) else { return }

        
        if cornerType == .all {
            if shadowLayerMode == .lightSide {
                if frame.size.width > shadowCornerRadius * 2 && frame.size.height > shadowCornerRadius * 2 {
                    ctx.setFillColor(color)
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
                    ctx.setFillColor(color)
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
                ctx.setFillColor(color)
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
                ctx.setFillColor(color)
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
            ctx.setFillColor(color)
            if shadowLayerMode == .lightSide {
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
