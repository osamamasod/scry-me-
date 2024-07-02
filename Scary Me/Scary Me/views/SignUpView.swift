import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showPassword = false
    @State private var showRepeatPassword = false
    @StateObject private var signUpViewModel = SignUpViewModel()
    
 
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var repeatPasswordError = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding(.bottom, 40)
                        .offset(x:-86,y:10)
                        .bold()
                    
                    // Logging email input
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
                    
                    // Logging password input
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
                    
                    // Logging repeat password input
                    FloatingTextField(text: $repeatPassword, placeholder: "Repeat Password")
                        .padding()
                        .background(Color(red: 62/255, green: 28/255, blue: 51/255))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .overlay(
                            Text(repeatPasswordError)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                                .opacity(repeatPasswordError.isEmpty ? 0 : 1),
                            alignment: .topLeading
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        handleSignUp()
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: 300)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                    .shadow(color: .red, radius: 15, y: 5)
                    
                    // Display error message
                    if let errorMessage = signUpViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $signUpViewModel.navigateToCreateProfile) {
                CreateProfileView()
            }
        }
    }
    
    private func handleSignUp() {
       
        print("Handling sign up...")
        
        // Reset error messages
        emailError = ""
        passwordError = ""
        repeatPasswordError = ""
        
     
        print("Before validation...")
        
       
        if isFormValid() {
            signUpViewModel.register(email: email, password: password)
        }
    }
    
    private func isFormValid() -> Bool {
        var isValid = true

        // Email validation
        if !isValidEmail(email) {
            emailError = "Invalid email format"
            isValid = false
        } else {
            emailError = ""
        }

        // Password validation
        if password.isEmpty || password.count < 8 {
            passwordError = password.isEmpty ? "Password is required" : "Password must be at least 8 characters"
            isValid = false
        } else {
            passwordError = ""
        }

      
        if repeatPassword.isEmpty || password != repeatPassword {
            repeatPasswordError = repeatPassword.isEmpty ? "Repeat password is required" : "Passwords do not match"
            isValid = false
        } else {
            repeatPasswordError = ""
        }

        print("Is form valid? \(isValid)")

        return isValid
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
