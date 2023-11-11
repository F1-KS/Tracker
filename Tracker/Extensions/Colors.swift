import UIKit

extension UIView {
    func setBorder(width: CGFloat, colorName: String) {
        layer.borderWidth = width
        let color = UIColor.color(for: colorName)
        layer.borderColor = color.cgColor
    }
}

extension UIColor {
    static let colorNames = [
        "ypBlackDay",
        "ypGray",
        "ypRed",
        "ypBlue",
        "ypWhiteDay",
        "ypLightGray",
        "ypColorSelection1",
        "ypColorSelection2",
        "ypColorSelection3",
        "ypColorSelection4",
        "ypColorSelection5",
        "ypColorSelection6",
        "ypColorSelection7",
        "ypColorSelection8",
        "ypColorSelection9",
        "ypColorSelection10",
        "ypColorSelection11",
        "ypColorSelection12",
        "ypColorSelection13",
        "ypColorSelection14",
        "ypColorSelection15",
        "ypColorSelection16",
        "ypColorSelection17",
        "ypColorSelection18",
        "ypBlackNight",
        "ypWhiteNight",
        "ypBackgroundDay",
        "ypBackgroundNight"
    ]
    
    static var colors: [String: UIColor] = [:]
    
    static func color(for name: String) -> UIColor {
        if let color = colors.updateValue(UIColor(named: name) ?? UIColor.black, forKey: name) {
            return color
        } else {
            return colors[name]!
        }
    }
}
