//
//  MetadataObjectShape.swift
//  MetadataObjectPicker
//
//  Created by Sebastian Owodzin on 31/03/2017.
//  Copyright © 2017 mobiletoolkit.org. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

public protocol MetadataObjectShape {
    var color: UIColor { get }

    var selected: Bool { get }

    var shapeLayer: CALayer { get }

    var metadataObject: AVMetadataObject { get }

    init(metadataObject: AVMetadataObject, color: UIColor)

    func isEqual(to anotherMetadataObject: AVMetadataObject) -> Bool
}

extension MetadataObjectShape {
    var selectedColor: UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0.25

        self.color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
