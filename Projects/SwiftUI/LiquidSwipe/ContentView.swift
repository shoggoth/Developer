//
//  ContentView.swift
//  LiquidSwipe
//
//  Created by Richard Henry on 19/05/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

// MARK: -

struct Home: View {
    
    @State private var offset = CGSize.zero
    @State private var showHome = false
    
    var body: some View {
        ZStack {
            Color("Background")
                .overlay(
                    VStack(alignment: .leading, spacing: 10.0) {
                        Text("For Lamers")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        Text("Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 30.0)
                    .foregroundColor(.primary)
                    .offset(x: -15, y: 0)
                )
        }
        .clipShape(LiquidSwipe(offset: offset))
        .ignoresSafeArea()
        
        .overlay(
            Image(systemName: "chevron.left")
                .frame(width: 50.0, height: 50.0)
                .font(.largeTitle)
                .contentShape(Rectangle())
                .gesture(DragGesture().onChanged({ value in
                    withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.6)) {
                        offset = value.translation
                    }
                }).onEnded({ value in
                    let screen = UIScreen.main.bounds
                    
                    withAnimation(.spring()) {
                        if -offset.width > screen.width * 0.5 {
                            offset.width = -screen.height
                            showHome.toggle()
                        } else {
                            offset = .zero
                        }
                    }
                }))
                .offset(x: 15, y: 84)
                .opacity(offset == .zero ? 1 : 0)
            , alignment: .topTrailing
        )
        
        if showHome {
            Text("Welcome to home")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .onTapGesture {
                    withAnimation(.spring()) {
                        offset = .zero
                        showHome.toggle()
                    }
                }
        }
    }
}

// MARK: -

struct LiquidSwipe: Shape {
    
    var offset: CGSize
    var animatableData: CGSize.AnimatableData {
        get { offset.animatableData }
        set { offset.animatableData = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        
        return Path { path in
            
            let width = rect.width + (-offset.width > 0 ? offset.width : 0)
            
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
            let foo = CGFloat(80)
            let from = foo + offset.width
            path.move(to: CGPoint(x: rect.width, y: from > foo ? foo : from))
            
            let bar = CGFloat(180)
            var to = bar + offset.height - offset.width
            to = to < bar ? bar : to
            path.move(to: CGPoint(x: rect.width, y: from > foo ? foo : from))
            
            let mid = foo + (to - foo) * 0.5
            let control = CGPoint(x: width - 50, y: mid)
            
            path.addCurve(to: CGPoint(x: rect.width, y: to), control1: control, control2: control)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView()
            .preferredColorScheme(.dark)
    }
}
