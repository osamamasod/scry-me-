import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @StateObject private var signInViewModel = SignInViewModel()

  
    @State private var emailError = ""
    @State private var passwordError = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Sign In")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding(.bottom, 40)
                        .offset(x: -86, y: 10)
                        .bold()
                    
                    FloatingTextField(text: $email, placeholder: "Email")
                        .padding()
                        .background(Color(red: 62/255, green: 28/255, blue: 51/255))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .overlay(
                            Text(emailError)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                                .opacity(emailError.isEmpty ? 0 : 1),
                            alignment: .topLeading
                        )
                    
                    FloatingTextField(text: $password, placeholder: "Password")
                        .padding()
                        .background(Color(red: 62/255, green: 28/255, blue: 51/255))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .overlay(
                            Text(passwordError)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                                .opacity(passwordError.isEmpty ? 0 : 1),
                            alignment: .topLeading
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        handleSignIn()
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                    .shadow(color: .red, radius: 15, y: 5)
                    
                  
                    if let errorMessage = signInViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $signInViewModel.navigateToNextView) {
                MainScreen(selectedTab: .tinder)
            }
        }
    }
    
    private func handleSignIn() {
       
        emailError = ""
        passwordError = ""
        
      
        if isFormValid() {
            signInViewModel.signIn(email: email, password: password)
        }
    }
    
    private func isFormValid() -> Bool {
        var isValid = true
        
    
        if !isValidEmail(email) {
            emailError = "Invalid email format"
            isValid = false
        }
        
     
        if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
            isValid = false
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
      //regex 
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
