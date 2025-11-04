//
//  RippleModifier.swift
//  RippleModifier
//
//  Created by Nozhan A. on 9/28/25.
//

import SwiftUI

struct RippleModifier: ViewModifier {
    var speed: Float = 1.0
    var aberration: Float = 0.2
    var ringThickness: Float = 0.45
    var intensity: Float = 0.15
    var isRippling: Bool
    var tapLocation = CGPoint.zero

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            Group {
                if isRippling {
                    let startDate = Date.now
                    let tap = tapLocation
                    TimelineView(.animation) { timeline in
                        let timeOffset = timeline.date.timeIntervalSince(startDate)
                        content
                            .drawingGroup()
                            .visualEffect { c, proxy in
                                let center = CGVector(
                                    dx: tap.x,
                                    dy: tap.y
                                )
                                return c.layerEffect(
                                    ShaderLibrary.bundle(.module).ripple(
                                        .float2(center),
                                        .float2(proxy.size),
                                        .float(timeOffset),
                                        .float(speed * 1.35),
                                        .float(aberration),
                                        .float(ringThickness),
                                        .float(intensity)
                                    ),
                                    maxSampleOffset: .zero
                                )
                            }
                    }
                    .id(startDate)
                } else {
                    content
                }
            }
        } else {
            content
        }
    }
}

extension View {
    public func rippling(
        speed: Float = 1.0,
        aberration: Float = 0.2,
        ringThickness: Float = 0.45,
        intensity: Float = 0.15,
        isRippling: Bool = false,
        tapLocation: CGPoint = .zero
    ) -> some View {
        modifier(
            RippleModifier(
                speed: speed,
                aberration: aberration,
                ringThickness: ringThickness,
                intensity: intensity,
                isRippling: isRippling,
                tapLocation: tapLocation,
            )
        )
    }
}

#Preview {
    @State var speed: Float = 1.0
    @State var aberration: Float = 0.2
    @State var thickness: Float = 0.45
    @State var intensity: Float = 0.15
    
    Image("test", bundle: .module)
        .resizable().scaledToFit()
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        .rippling(speed: speed, aberration: aberration, ringThickness: thickness, intensity: intensity)
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            Grid(horizontalSpacing: 16, verticalSpacing: 8) {
                Group {
                    GridRow {
                        Text("Speed: \(speed.formatted(.number.precision(.fractionLength(2))))")
                        Slider(value: $speed, in: 0.5...2.5)
                    }
                    GridRow {
                        Text("Aberration: \(aberration.formatted(.number.precision(.fractionLength(2))))")
                        Slider(value: $aberration, in: 0...1)
                    }
                    GridRow {
                        Text("Thickness: \(thickness.formatted(.number.precision(.fractionLength(2))))")
                        Slider(value: $thickness, in: 0...1)
                    }
                    GridRow {
                        Text("Intensity: \(intensity.formatted(.number.precision(.fractionLength(2))))")
                        Slider(value: $intensity, in: 0...1)
                    }
                }
                .gridColumnAlignment(.leading)
            }
            .padding(16)
        }
}
