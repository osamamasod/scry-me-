//
//  CircleView.swift
//  Scary Me
//
//  Created by Osama Masoud on 7/2/24.
//

import SwiftUI
import SwiftUI

struct CircleView: View {
    @State private var position: CGPoint
    @State private var velocity: CGSize
    @State private var size: CGFloat = 100 
    @State private var timer: Timer?

    var imageName: String

    init(startPosition: CGPoint, startVelocity: CGSize, imageName: String) {
        _position = State(initialValue: startPosition)
        _velocity = State(initialValue: startVelocity)
        self.imageName = imageName
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                )
                .position(position)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updatePosition()
        }
    }

    private func updatePosition() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let limitHeight = screenHeight * 0.75 //  the limit height to be above the "Sign Up" button

        var newPosition = CGPoint(x: position.x + velocity.width, y: position.y + velocity.height)
        
  
        if newPosition.x - size / 2 < 0 || newPosition.x + size / 2 > screenWidth {
            velocity.width *= -1
        }
        if newPosition.y - size / 2 < 0 || newPosition.y + size / 2 > limitHeight {
            velocity.height *= -1
        }
        
        position = CGPoint(x: position.x + velocity.width, y: position.y + velocity.height)
    }
}
