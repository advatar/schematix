//
//  DID.swift
//  Base64
//
//  Created by Johan Sellström on 2019-01-19.
//

import UIKit

public let cache = NSCache<AnyObject, UIImage>()

public typealias JSON = [String: Any]


public func generateMonogram(fullname: String) -> String {
    var monogram = "??"
    let name = fullname.components(separatedBy: " ")

    if name.isEmpty {
        return monogram
    } else if name.count == 1 {
        if let firstName = name.first, !firstName.isEmpty {
            monogram = String(firstName.first!) + String(firstName.first!)
        }
    } else {
        if let firstName = name.first, let lastName = name.last {
            monogram = String(firstName.first!) + String(lastName.first!)
        }
    }
    return monogram
}

public extension UITableView {
    func scrollToBottom(animated: Bool) {
        let numberOfRows = self.numberOfRows(inSection: 0)
        guard numberOfRows > 0 else { return }
        let lastRow = IndexPath(row: (numberOfRows-1), section: 0)
        self.scrollToRow(at: lastRow, at: .bottom, animated: animated)
        // let y = contentSize.height - frame.size.height
        // setContentOffset(CGPoint(x: 0, y: (y<0) ? 0 : y), animated: animated)
    }
}

public extension UIView {

    func imageWithView() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }

    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }


    func center_X(item: UIView) {
        center_X(item: item, constant: 0)
    }

    func center_X(item: UIView, constant: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: constant))
    }

    func center_Y(item: UIView, constant: CGFloat) {
        self.addConstraint(NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: constant))
    }

    func center_Y(item: UIView) {
        center_Y(item: item, constant: 0)
    }

}

public extension Date {
    var relativeDateString: String {
        if Calendar.current.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: self)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: self)
        }
    }
}

public extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else {
                continue
            }
            self.swapAt(i, j)
        }
    }
}

public extension String {

    func slice(from: String, to: String) -> String? {

        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }

    /// Returns the localized string value
    var localized: String {
        return localize(withBundle: Bundle.main)
    }

    func localize(withBundle bundle: Bundle) -> String
    {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }

    func image() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func base64ToImage() -> UIImage? {

        if let data =  Data(base64Encoded: self, options: .ignoreUnknownCharacters) , let image = UIImage(data: data) {
            return image
        }
        return nil
    }

    func base64URLToImage() -> UIImage? {
        //let results = self.matches(for: "data:image\\/([a-zA-Z]*);base64,([^\\\"]*)")
        let arr = self.components(separatedBy: ";base64,")
        //print(arr)
        if !arr.isEmpty {
            //print(arr[arr.count-1])
            return arr[arr.count-1].base64ToImage()
        }
        return nil
    }


    func base64URLToString() -> String? {
        //let results = self.matches(for: "data:image\\/([a-zA-Z]*);base64,([^\\\"]*)")
        let arr = self.components(separatedBy: ";base64,")
        //print(arr)
        if !arr.isEmpty {
            //print(arr[arr.count-1])
            return arr[arr.count-1]
        }
        return nil
    }

    func toJSON() -> [String:Any]? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
    }

    static func random(length: Int = 20) -> String {
        let base = "abcdefABCDEF0123456789"
        var randomString: String = ""
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }

}


//MARK: Image Extensions
public extension UIImageView {
    func loadImage(_ url: String, completion: (() -> Void)? = nil) {
        if let image = cache.object(forKey: "url" as AnyObject) {
            self.image = image
            return
        }

        if let image = UIImage(named:"profile_selected") {
            cache.setObject(image, forKey: "url" as AnyObject)
        }
        completion?()
    }
}


public extension URL {
    func getData( completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: self, completionHandler: completion).resume()
    }
}

public extension UIColor {

    func interpolate(with other: UIColor, percent: CGFloat) -> UIColor? {
        return UIColor.interpolate(betweenColor: self, and: other, percent: percent)
    }

    static func interpolate(betweenColor colorA: UIColor,
                            and colorB: UIColor,
                            percent: CGFloat) -> UIColor? {
        var redA: CGFloat = 0.0
        var greenA: CGFloat = 0.0
        var blueA: CGFloat = 0.0
        var alphaA: CGFloat = 0.0
        guard colorA.getRed(&redA, green: &greenA, blue: &blueA, alpha: &alphaA) else {
            return nil
        }

        var redB: CGFloat = 0.0
        var greenB: CGFloat = 0.0
        var blueB: CGFloat = 0.0
        var alphaB: CGFloat = 0.0
        guard colorB.getRed(&redB, green: &greenB, blue: &blueB, alpha: &alphaB) else {
            return nil
        }

        let iRed = CGFloat(redA + percent * (redB - redA))
        let iBlue = CGFloat(blueA + percent * (blueB - blueA))
        let iGreen = CGFloat(greenA + percent * (greenB - greenA))
        let iAlpha = CGFloat(alphaA + percent * (alphaB - alphaA))

        return UIColor(red: iRed, green: iGreen, blue: iBlue, alpha: iAlpha)
    }
}

public extension UIImage {

    func resize(to newSize: CGSize) -> UIImage? {
        guard self.size != newSize else { return self }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func pixelBuffer() -> CVPixelBuffer? {

        let width = Int(self.size.width)
        let height = Int(self.size.height)

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }

        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}

public extension UIViewController {

    func addCancelButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onClose))
    }

    @objc func onClose() {
        self.dismiss(animated: true, completion: nil)
    }

    func show(error: Error, title: String) {
        let msg = (NSCocoaErrorDomain == error._domain) ? error.localizedDescription : "\(error)"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


public enum Colors {

    case red, green, blue, lightBlue, pink, purple, yellow

    public var color: UIColor {
        switch self {
        case .red:
            return UIColor(red: 0xEF / 255.0, green: 0x44 / 255.0, blue: 0x5B / 255.0, alpha: 1.0)

        case .green:
            return UIColor(red: 0x8D / 255.0, green: 0xC6 / 255.0, blue: 0x3F / 255.0, alpha: 1.0)

        case .blue:
            return UIColor(red: 0x3E / 255.0, green: 0xA1 / 255.0, blue: 0xEE / 255.0, alpha: 1.0)

        case .lightBlue:
            return UIColor(red: 0x9C / 255.0, green: 0xCF / 255.0, blue: 0xF8 / 255.0, alpha: 1.0)

        case .pink:
            return UIColor(red: 0xF2 / 255.0, green: 0x6D / 255.0, blue: 0x7D / 255.0, alpha: 1.0)

        case .purple:
            return UIColor(red: 0x9B / 255.0, green: 0x59 / 255.0, blue: 0xB6 / 255.0, alpha: 1.0)

        case .yellow:
            return UIColor(red: 0xF1 / 255.0, green: 0xDF / 255.0, blue: 0x15 / 255.0, alpha: 1.0)
        }
    }
}


public enum OCKColors {
    case red, green, blue, lightBlue, pink, purple, yellow, drawer
    public var color: UIColor {
        switch self {
        case .red:
            return UIColor(red: 0xEF / 255.0, green: 0x44 / 255.0, blue: 0x5B / 255.0, alpha: 1.0)
        case .green:
            return UIColor(red: 0x8D / 255.0, green: 0xC6 / 255.0, blue: 0x3F / 255.0, alpha: 1.0)
        case .blue:
            return UIColor(red: 0x3E / 255.0, green: 0xA1 / 255.0, blue: 0xEE / 255.0, alpha: 1.0)
        case .lightBlue:
            return UIColor(red: 0x9C / 255.0, green: 0xCF / 255.0, blue: 0xF8 / 255.0, alpha: 1.0)
        case .pink:
            return UIColor(red: 0xF2 / 255.0, green: 0x6D / 255.0, blue: 0x7D / 255.0, alpha: 1.0)
        case .purple:
            return UIColor(red: 0x9B / 255.0, green: 0x59 / 255.0, blue: 0xB6 / 255.0, alpha: 1.0)
        case .yellow:
            return UIColor(red: 0xF1 / 255.0, green: 0xDF / 255.0, blue: 0x15 / 255.0, alpha: 1.0)
        case .drawer:
            return UIColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1.0)
        }
    }
}

public extension UIColor {

    //MARK: function
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }

    //MARK: Colors
    static let lighterBlack = UIColor(r: 234, g: 234, b: 234)
    static let textfiled = UIColor(r: 250, g: 250, b: 250)
    static let blueInstagram = UIColor(r: 69, g: 142, b: 255)
    static let blueInstagramLighter = UIColor(r: 69, g: 142, b: 195)
    static let blueButton = UIColor(r: 154, g: 204, b: 246)
    static let buttonUnselected = UIColor(white: 0, alpha: 0.25)
    static let shareBackground = UIColor(r: 240, g: 240, b: 240)
    static let searchBackground = UIColor(r: 230, g: 230, b: 230)
    static let seperator = UIColor(white: 0, alpha: 0.50)
    static let highlightedButton = UIColor(r: 17, g: 154, b: 237)
    static let save = UIColor(white: 0, alpha: 0.3)
}
