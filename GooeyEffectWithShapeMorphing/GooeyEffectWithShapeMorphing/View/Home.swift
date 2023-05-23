//
//  Home.swift
//  GooeyEffectWithShapeMorphing
//
//  Created by Vadim Shinkarenko on 19.05.2023.
//

import SwiftUI

struct Home: View {
    var size: CGSize
    /// View Properties
    @State private var isExpanded: Bool = false
    @State private var radius: CGFloat = 10
    @State private var animatedRadius: CGFloat = 10
    @State private var scale: CGFloat = 1
    /// Offsets
    @State private var baseOffset: [Bool] = Array(repeating: false, count: 5)
    @State private var secondaryOffset: [Bool] = Array(repeating: false, count: 2)
    /// Icons will First Visible on the Base offset and continues to secondary Offset
    @State private var showIcons: [Bool] = [false, false]
    @State private var dispatchTask: DispatchWorkItem?
    
    var body: some View {
        
        VStack {
            /// Share Button
            /// Since we have 5 buttons
            /// Applying Padding
            let padding: CGFloat = 30
            let circleSize = (size.width - padding) / 5
            ZStack {
                ShapeMorphingView(systemImage: isExpanded ? "xmark.circle.fill" : "square.and.arrow.up.fill", fontSize: isExpanded ? circleSize * 0.9 : 35, color: .white)
                    .scaleEffect(isExpanded ? 0.6 : 1)
                    .background {
                        Rectangle()
                            .fill(.gray.gradient)
                            .mask {
                                Canvas { ctx, size in
                                    /// Same Technique as Shape Morph
                                    ctx.addFilter(.alphaThreshold(min: 0.5))
                                    ctx.addFilter(.blur(radius: animatedRadius))
                                    
                                    /// Drawing Symbols
                                    ctx.drawLayer { ctx1 in
                                        /// Since there are 5 Circles with 5 Tags
                                        for index in 0..<5 {
                                            if let resolvedShareButton = ctx.resolveSymbol(id: index) {
                                                ctx1.draw(resolvedShareButton, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                            }
                                        }
                                    }
                                } symbols: {
                                    GroupedShareButtons(size: circleSize, fillColor: true)
                                }

                            }
                    }
                
                GroupedShareButtons(size: circleSize, fillColor: false)
            }
            .frame(height: circleSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: isExpanded) { newValue in
            if newValue {
                /// First Dispaying Base Offset Icons
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                    showIcons[0] = true
                }
                /// Next Dispaying Secondary Offset Icons
                withAnimation(.easeInOut(duration: 0.3).delay(0.2)) {
                    showIcons[1] = true
                }
            } else {
                /// No Delay for Hiding Icons
                withAnimation(.easeInOut(duration: 0.15)) {
                    showIcons[0] = false
                    showIcons[1] = false
                }
            }
        }
    }
    /// Share Bitton's
    @ViewBuilder
    func GroupedShareButtons(size: CGFloat, fillColor: Bool = true) -> some View {
        Group {
            ShareButton(size: size, tag: 0, icon: "calendar.circle.fill", showIcon: showIcons[1]) {
                return (baseOffset[0] ? -size : 0) + (secondaryOffset[0] ? -size : 0)
            }
            .onTapGesture {
                print("1")
            }
            
            ShareButton(size: size, tag: 1, icon: "tray.circle.fill", showIcon: showIcons[0]) {
                return (baseOffset[1] ? -size : 0)
            }
            .onTapGesture {
                print("2")
            }
            
            ShareButton(size: size, tag: 2, icon: "", showIcon: true) {
                return 0
            }
            /// Making it Top of all Views, for initial Tap
            .zIndex(100)
            .onTapGesture(perform: toggleShareButton)
            .onTapGesture {
                print("Share")
            }
            
            ShareButton(size: size, tag: 3, icon: "book.circle.fill", showIcon: showIcons[0]) {
                return (baseOffset[3] ? size : 0)
            }
            .onTapGesture {
                print("4")
            }
            
            ShareButton(size: size, tag: 4, icon: "paperclip.circle.fill", showIcon: showIcons[1]) {
                return (baseOffset[4] ? size : 0)  + (secondaryOffset[1] ? size : 0)
            }
            .onTapGesture {
                print("5")
            }
        }
        .foregroundColor(fillColor ? .black : .clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animationProgress(endValue: radius) { value in
            animatedRadius = value
            
            if value >= 15 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    radius = 10
                }
            }
        }
    }
    
    /// Individual Share Button
    @ViewBuilder
    func ShareButton(size: CGFloat, tag: Int, icon: String, showIcon: Bool, offset: @escaping () -> CGFloat) -> some View {
        Circle()
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .overlay {
                if icon != "" {
//                    Image(icon)
                    Image(systemName: icon)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: size * 0.3)
                        /// Showing Icon when the ShowIcon is True
                        .opacity(showIcon ? 1 : 0)
                        .scaleEffect(showIcon ? 1 : 0.001)
                }
            }
            .contentShape(Circle())
            .offset(x: offset())
            .tag(tag)
    }
    
    /// Togglish Share Button
    func toggleShareButton() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.4)) {
            isExpanded.toggle()
            scale = isExpanded ? 0.75 : 1
        }
        
        /// Updating Radius for More Fludity
        withAnimation(.easeInOut(duration: 0.4)) {
            radius = 20
        }
        
        for index in baseOffset.indices {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.8)) {
                baseOffset[index].toggle()
            }
        }
        
        if let dispatchTask {
            dispatchTask.cancel()
        }
        
        dispatchTask = .init(block: {
            for index in secondaryOffset.indices {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.8)) {
                    secondaryOffset[index].toggle()
                }
            }
        })
        
        if let dispatchTask {
            /// No Delay Needed for Closing
            DispatchQueue.main.asyncAfter(deadline: .now() + (isExpanded ? 0.15 : 0), execute: dispatchTask)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
