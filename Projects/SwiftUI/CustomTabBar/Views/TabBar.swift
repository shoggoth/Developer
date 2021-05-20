//
//  TabBar.swift
//  CustomTabBar
//
//  Created by Richard Henry on 20/05/2021.
//

import SwiftUI

struct TabBar: View {
    
    @State private var tabPoints = [CGFloat]()
    
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(systemImageName: "house", selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(systemImageName: "bookmark", selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(systemImageName: "message", selectedTab: $selectedTab, tabPoints: $tabPoints)
            TabBarButton(systemImageName: "heart", selectedTab: $selectedTab, tabPoints: $tabPoints)
        }
        .padding()
        .background(
            Color.white
                .clipShape(TabCurve(tabPoint: getCurvePoint() - 15))
        )
        .overlay(
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .offset(x: getCurvePoint() - 20)
            
            ,alignment: .bottomLeading
        )
        .cornerRadius(23)
        .padding(.horizontal)
    }
    
    private func getCurvePoint() -> CGFloat {
        
        // TODO: Lame. Replace this
        if tabPoints.isEmpty { return 10 }
        
        else {
            switch selectedTab {
            case "house":
                return tabPoints[0]
            case "bookmark":
                return tabPoints[1]
            case "message":
                return tabPoints[2]
            default:
                return tabPoints[3]
            }
        }
    }
}

// MARK: -

struct TabBarButton: View {
    
    var systemImageName: String
    
    @Binding var selectedTab: String
    @Binding var tabPoints: [CGFloat]

    var body: some View {
        HStack(spacing: 0) {
            GeometryReader { geo -> AnyView in
                let midX = geo.frame(in: .global).midX
                
                DispatchQueue.main.async {
                    if tabPoints.count <= 4 { tabPoints.append(midX) }
                }
                
                return AnyView(
                    Button(action: {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.5)) { selectedTab = systemImageName }
                    }, label: {
                        
                        let isSelected = selectedTab == systemImageName
                        
                        Image(systemName:"\(systemImageName)\(isSelected ? ".fill" : "")")
                            .font(.system(size: 25, weight: .semibold))
                            .foregroundColor(Color("TabSelected"))
                            .offset(y: isSelected ? -10 : 0)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                )
            }
            .frame(height: 50)
        }
    }
}

// MARK: -

struct TabCurve: Shape {
    
    var tabPoint: CGFloat
    
    var animatableData: CGFloat {
        get { tabPoint }
        set { tabPoint = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        
        Path { path in
            path.move(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
            let mid = tabPoint
            path.move(to: CGPoint(x: mid - 40, y: rect.height))
            
            let to1 = CGPoint(x: mid, y: rect.height - 20)
            let control1 = CGPoint(x: mid - 15, y: rect.height)
            let control2 = CGPoint(x: mid - 15, y: rect.height - 20)
            
            let to2 = CGPoint(x: mid + 40, y: rect.height)
            let control3 = CGPoint(x: mid + 15, y: rect.height - 20)
            let control4 = CGPoint(x: mid + 15, y: rect.height)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}

// MARK: -

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
