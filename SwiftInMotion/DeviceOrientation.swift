//
//  DeviceOrientation.swift
//  SwiftInMotion
//
//  Created by Mauricio Cardozo on 8/3/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

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
