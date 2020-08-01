//
//  ContentView.swift
//  SwiftInMotion
//
//  Created by Mauricio Cardozo on 8/1/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import SwiftUI
import CoreMotion
import Combine

struct ContentView: View {
    var body: some View {
        Card()
    }
}

struct Card: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            MotionReader { offset in
                Image("porsche")
                .resizable()
                .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.2)
                .offset(offset)
            }
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.3), .clear]),
                           startPoint: .top, endPoint: .bottom)
            Text("Porsche")
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .shadow(radius: 1)
                .padding()
        }
        .aspectRatio(16/9, contentMode: .fit)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

struct MotionReader<Content>: View where Content: View {

    private let contentView: (CGSize) -> Content
    private let motionManager = CMMotionManager()
    private let strength: Double
    private let minimum: Double
    private let maximum: Double
    @State private var initialOffset: CGSize = .zero
    @State private var currentOffset: CGSize = .zero
    @State private var timer = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()
    @ObservedObject var deviceOrientation = DeviceOrientation()

    init(motionRange: ClosedRange<Double> = (-50.0...50.0),
         motionStrength: Double = 50,
         @ViewBuilder content: @escaping (CGSize) -> Content) {
        minimum = motionRange.lowerBound
        maximum = motionRange.upperBound
        contentView = content
        strength = motionStrength
    }

    var body: some View {
        contentView(currentOffset)
            // without an animation, we're getting unsmoothed raw data
            // so we abstract the animation right into the motion reader
            .animation(.linear)
            .onAppear {
                guard self.shouldEnableMotion else { return }
                self.motionManager.accelerometerUpdateInterval = 1/30
                self.motionManager.startAccelerometerUpdates()
            }
            .onReceive(timer) { publisher in
                guard self.shouldEnableMotion,
                    let data = self.motionManager.accelerometerData else { return }

                let accel = data.acceleration
                self.currentOffset = self.calculateOffsetForCurrentOrientation(x: accel.x, y: accel.y)
            }
    }

    // it is necessary to rotate the data based on
    // device's current orientation
    private func calculateOffsetForCurrentOrientation(x: Double, y: Double) -> CGSize {

        // clamping values so offset doesn't extrapolate
        let initialXAxis = max(minimum, min((x * strength), maximum))
        let initialYAxis = max(minimum, min((y * strength), maximum))

        switch deviceOrientation.deviceOrientation {
        case .portrait:
            return CGSize(width: initialXAxis, height: initialYAxis)
        case .portraitUpsideDown:
            return CGSize(width: -initialXAxis, height: -initialYAxis)
        case .landscapeLeft:
            return CGSize(width: -initialYAxis, height: -initialXAxis)
        case .landscapeRight:
            return CGSize(width: initialYAxis, height: initialXAxis)
        default:
            return .zero
        }
    }

    private var shouldEnableMotion: Bool {
        !ProcessInfo.processInfo.isLowPowerModeEnabled && motionManager.isAccelerometerAvailable
    }
}

final class DeviceOrientation: ObservableObject {
    private var observer: AnyCancellable?
    @Published var deviceOrientation: UIDeviceOrientation

    init() {
        deviceOrientation = UIDevice.current.orientation
        observeOrientation()
    }

    private func observeOrientation() {
        observer = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap({ $0.object as? UIDevice})
            .sink { [weak self] device in
                self?.deviceOrientation = device.orientation
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
