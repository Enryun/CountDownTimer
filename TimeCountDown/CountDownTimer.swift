//
//  CountDownTimer.swift
//  TimeCountDown
//
//  Created by James Thang on 16/05/2022.
//

import SwiftUI

struct CountDownTimer: View {
    
    var totalTime = 60
    @State private var timeRemaining = 60
    @State private var isActive = true

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var bonusTimeLimit: TimeInterval = 1
    @State private var animatedBonusRemaining: Double = 0
    private var bonusTimeRemaining: TimeInterval {
        max(0, bonusTimeLimit)
    }
    
    private var bonusRemaining: Double {
        (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
    }
    
    var body: some View {
        ZStack {
            
            Group {
                Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - animatedBonusRemaining) * 360 - 90))
                    .onReceive(timer) { time in

                        guard isActive else { return }

                        if timeRemaining > 0 {
                            animatedBonusRemaining = bonusRemaining
                            withAnimation(.linear(duration: bonusTimeRemaining)) {
                                animatedBonusRemaining = 0
                            }
                        }
                    }
            }
            .padding(5)
            .opacity(0.5)
            .foregroundColor((Double(timeRemaining) / Double(totalTime)) > 0.25 ? .green : .red)
            
            Text("\(timeRemaining)")
                .font(.title)
                .onReceive(timer) { time in

                    guard isActive else { return }

                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { (_) in
                    isActive = true
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { (_) in
                    isActive = false
                }
        }
        .frame(width: 200, height: 200, alignment: .center)
    }
    
    
}


struct Pie: Shape {
    
    var startAngle: Angle
    var endAngle: Angle
    var clockWise = false
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(startAngle.radians, endAngle.radians)
        }
        
        set {
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height)/2
        let startPoint = CGPoint(
            x: center.x + radius * CGFloat(cos(startAngle.radians)),
            y: center.y + radius * CGFloat(sin(startAngle.radians))
        )
        
        var path = Path()
        path.move(to: center)
        path.addLine(to: startPoint)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: !clockWise)
        path.addLine(to: center)
        
        return path
    }
    
    
}

