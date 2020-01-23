# EMTNeumorphicView
UIKit views with Neumorphism style design.

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org) 
[![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

<img src="https://www.emotionale.jp/images/git/emtneumorphicview/screen.jpg" width="480px">

## Installation
EMTNeumorphicView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EMTNeumorphicView'
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

You can use EMTNeumorphicView / EMTNeumorphicButton / EMTNeumorphicTableCell.
Each view is a subclass of UIView / UIButton/ UITableViewCell.

### EMTNeumorphicView
```swift
    let myView = EMTNeumorphicView()
    myView.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor
    myView.neumorphicLayer?.cornerRadius = 24
    // set convex or concave.
    myView.neumorphicLayer?.depthType = .concave
    // set elementDepth (corresponds to shadowRadius). Default is 7.15
    myView.neumorphicLayer?.elementDepth = 10
```

### EMTNeumorphicButton

<img src="https://www.emotionale.jp/images/git/emtneumorphicview/buttons.gif" width="480px">

Basically equivalent to EMTNeumorphicView.

```swift
    let button = EMTNeumorphicButton(type: .custom)
    button.setImage(UIImage(named: "heart-outline"), for: .normal)
    button.setImage(UIImage(named: "heart-solid"), for: .selected)
    button.contentVerticalAlignment = .fill
    button.contentHorizontalAlignment = .fill
    button.imageEdgeInsets = UIEdgeInsets(top: 26, left: 24, bottom: 22, right: 24)
    button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
    
    button.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor

    @objc func tapped(_ button: EMTNeumorphicButton) {
        // isSelected property changes neumorphicLayer?.depthType automatically
        button.isSelected = !button.isSelected
    }
```

### EMTNeumorphicTableCell

```swift
    // change neumorphicLayer?.cornerType according to its row position
    var type: EMTNeumorphicLayerCornerType = .all
    if rowCount > 1 {
        if indexPath.row == 0 {
            type = .topRow
        }
        else if indexPath.row == rowCount - 1 {
            type = .bottomRow
        }
        else {
            type = .middleRow
        }
    }
    let cellId = String(format: "cell%d", type.rawValue)
    var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
    if cell == nil {
        cell = EMTNeumorphicTableCell(style: .default, reuseIdentifier: cellId)
    }
    if let cell = cell as? EMTNeumorphicTableCell {
        cell.neumorphicLayer?.cornerType = type
        cell.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor
    }
```

### Other Properties

```swift
    /// This value multiplies the brightness of light shadow. Default is 2.
    myView.neumorphicLayer?.brightness = 3

    /// Optional. if it is nil (default), elementBackgroundColor will be used as element color.
    myView.neumorphicLayer?.elementColor = UIColor.red.cgColor
    
    /// Adding a very thin border on the edge of the element.
    myView.neumorphicLayer?.edged = true
```

## Requirements
Swift 5 / iOS 13

## License
EMTNeumorphicView is available under the MIT license. See the LICENSE file for more info.
