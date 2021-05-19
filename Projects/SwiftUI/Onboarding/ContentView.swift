//
//  ContentView.swift
//  Onboarding
//
//  Created by Richard Henry on 19/05/2021.
//

import SwiftUI

private let totalPages = 3

struct ContentView: View {
    
    @AppStorage("currentPage") var currentPage = 1
    
    var body: some View {
        if currentPage > totalPages { Home() } else { WalkThroughScreen() }
    }
}

// MARK: -

struct Home: View {
    
    var body: some View {
        Text("Welcome to Homo")
            .font(.title)
            .fontWeight(.heavy)
    }
}

// MARK: -

struct WalkThroughScreen: View {
    
    @AppStorage("currentPage") var currentPage = 1

    var body: some View {
        ZStack {
            // Changing between views…
            // TODO: See if switch can be used with transitions
            
            if currentPage == 1 {
                ScreenView(imageName: "Image1", title: "Step 1", detail: "", backgroundColour: Color("Colour1")).transition(.scale)
            }
            else if currentPage == 2 {
                ScreenView(imageName: "Image2", title: "Step 2", detail: "", backgroundColour: Color("Colour2")).transition(.scale)
            }
            else if currentPage == 3 {
                ScreenView(imageName: "Image3", title: "Step 3", detail: "", backgroundColour: Color("Colour3")).transition(.scale)
            }
        }
        .overlay(
            Button(action: {
                withAnimation(.easeInOut) {
                    if currentPage <= totalPages { currentPage += 1 }
                }
            }, label: {
                Image(systemName:"chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.05), lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage) / CGFloat(totalPages))
                                .stroke(Color.black.opacity(0.05), lineWidth: 4)
                                .rotationEffect(.init(degrees: -90))
                        }
                        .padding(-15)
                    )
            })
            .padding(.bottom, 20)
            , alignment: .bottom
        )
    }
}

// MARK: -

struct ScreenView: View {
    
    @AppStorage("currentPage") var currentPage = 1

    let imageName: String
    let title: String
    let detail: String
    let backgroundColour: Color
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if currentPage == 1 {
                    Text("Hello, member!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .kerning(1.4)
                } else {
                    Button(action: {
                        withAnimation(.easeInOut) { currentPage -= 1 }
                    }, label: {
                        Image(systemName:"chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                    })
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut) { currentPage = 4 }
                }, label: {
                    Text("Skip")
                        .fontWeight(.semibold)
                        .kerning(1.4)
                })
            }
            .foregroundColor(.black)
            .padding()
            
            Spacer(minLength: 0)
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .padding(.top)
            
            Text("lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ")
                .fontWeight(.semibold)
                .kerning(1.3)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 120)
        }
        .background(backgroundColour.cornerRadius(10).ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView()
            .preferredColorScheme(.dark)
    }
}
