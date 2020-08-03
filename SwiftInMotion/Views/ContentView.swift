//
//  ContentView.swift
//  SwiftInMotion
//
//  Created by Mauricio Cardozo on 8/1/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MotionReader { proxy in
            Card().motionEffect()
        }
    }
}

struct Card: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("porsche")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .motionEffect()

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
