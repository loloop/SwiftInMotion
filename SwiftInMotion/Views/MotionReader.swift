//
//  MotionReader.swift
//  SwiftInMotion
//
//  Created by Mauricio Cardozo on 8/3/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import Foundation
import SwiftUI
import CoreMotion

struct MotionReader<Content>: View where Content: View {

    private let contentView: (MotionProxy) -> Content
    private let motionManager: CMMotionManager = .shared
    private let strength: Double
    private let minimum: Double
    private let maximum: Double
    @State private var currentOffset: MotionProxy = .zero
    @State private var timer = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()
    @ObservedObject var deviceOrientation = DeviceOrientation()
    @Environment(\.accessibilityReduceMotion) var isReduceMotionOn: Bool

    init(motionRange: ClosedRange<Double> = (-5.0...5.0),
         motionStrength: Double = 1,
         @ViewBuilder content: @escaping (MotionProxy) -> Content) {
        minimum = motionRange.lowerBound
        maximum = motionRange.upperBound
        contentView = content
        strength = motionStrength * 5
    }

    var body: some View {
        contentView(currentOffset)
            // without an animation, we're getting unsmoothed raw data
            // so we abstract the animation right into the motion reader
            .animation(.linear)
            .onAppear {
                guard self.shouldEnableMotion else { return }
                self.motionManager.gyroUpdateInterval = 1/30
                self.motionManager.startGyroUpdates()
            }
            .onDisappear {
                self.motionManager.stopAccelerometerUpdates()
            }
            .onReceive(timer) { publisher in
                guard self.shouldEnableMotion,
                    let data = self.motionManager.gyroData else { return }

                let rate = data.rotationRate
                self.currentOffset = self.calculateOffsetForCurrentOrientation(x: rate.x, y: rate.y, z: rate.z)
            }
    }

    // it is necessary to rotate the data based on
    // device's current orientation
    private func calculateOffsetForCurrentOrientation(x: Double, y: Double, z: Double) -> MotionProxy {

        // clamping values so offset doesn't extrapolate
        let xAxis = max(minimum, min((x * strength), maximum))
        let yAxis = max(minimum, min((y * strength), maximum))

        switch deviceOrientation.deviceOrientation {
        case .portrait:
            return MotionProxy(x: yAxis, y: xAxis, z: z)
        case .portraitUpsideDown:
            return MotionProxy(x: yAxis, y: -xAxis, z: z)
        case .landscapeLeft:
            return MotionProxy(x: -xAxis, y: -yAxis, z: z)
        case .landscapeRight:
            return MotionProxy(x: -xAxis, y: yAxis, z: z)
        case .unknown, .faceDown, .faceUp:
            return MotionProxy(x: xAxis, y: yAxis, z: z)
        @unknown default:
            return MotionProxy(x: xAxis, y: yAxis, z: z)
        }
    }

    private var shouldEnableMotion: Bool {
        !ProcessInfo.processInfo.isLowPowerModeEnabled &&
            motionManager.isAccelerometerAvailable &&
            !isReduceMotionOn
    }
}

struct MotionProxy {

    let x: CGFloat
    let y: CGFloat
    let z: CGFloat

    internal init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }

    internal init(x: Double, y: Double, z: Double) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        self.z = CGFloat(z)
    }

    static var zero: MotionProxy {
        MotionProxy(x: 0.0, y: 0, z: 0)
    }
}
