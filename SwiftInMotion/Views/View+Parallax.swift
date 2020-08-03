//
//  View+Parallax.swift
//  SwiftInMotion
//
//  Created by Mauricio Cardozo on 8/3/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func motionEffect(scale: CGFloat = 1.2, range: ClosedRange<Double> = (-5.0...5.0), strength: Double = 1) -> some View {
        MotionReader(motionRange: range, motionStrength: strength) { proxy in
            self
                .scaleEffect(scale)
                .offset(x: proxy.x, y: proxy.y)
        }
    }
}
