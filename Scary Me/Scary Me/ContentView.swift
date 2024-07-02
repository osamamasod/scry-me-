import SwiftUI

struct ContentView: View {
    @StateObject private var signUpViewModel = SignUpViewModel()
    @StateObject private var signInViewModel = SignInViewModel()
    
    @State private var isSignUpActive = false
    @State private var isSignInActive = false

    let imageNames = ["ttt", "rrr", "eee", "yyy", "uuu", "ooo"]
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Color.black.ignoresSafeArea(.all)
                }
                
                Image("ScareMe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .offset(x: 10, y: -6)
                
                Text("Don't have an account yet?")
                    .foregroundColor(.orange)
                    .font(.system(size: 17))
                    .padding(.bottom)
                    .offset(x: 10, y: 290)
                    .shadow(color: .red, radius: 15, y: 5)
                
                VStack {
                  
                    Button(action: {
                        isSignUpActive = true
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                    .offset(x: 2, y: 230)
                    .shadow(color: .red, radius: 15, y: 5)
                    .background(
                        NavigationLink(
                            destination: SignUpView(),
                            isActive: $isSignUpActive,
                            label: { EmptyView() }
                        )
                    )
                    
                  
                    Button(action: {
                        isSignInActive = true
                    }) {
                        Text("Sign In")
                            .foregroundColor(.orange)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .offset(x: 2, y: 300)
                    .shadow(color: .red, radius: 15, y: 5)
                    .background(
                        NavigationLink(
                            destination: SignInView(),
                            isActive: $isSignInActive,
                            label: { EmptyView() }
                        )
                    )
                }
                .padding()
                
                //  6 moving circles 
                ForEach(0..<6) { index in
                    CircleView(
                        startPosition: CGPoint(x: CGFloat.random(in: 50...350), y: CGFloat.random(in: 50...350)), // Adjust initial positions
                        startVelocity: CGSize(width: CGFloat.random(in: -2...2), height: CGFloat.random(in: -2...2)),
                        imageName: imageNames[index % imageNames.count]
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
