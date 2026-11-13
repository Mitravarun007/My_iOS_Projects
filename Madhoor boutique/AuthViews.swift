import SwiftUI

// MARK: - Welcome View
struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1A0533"), Color(hex: "#4A0E5E"), Color(hex: "#E91E8C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 350, height: 350)
                .offset(x: -100, y: -200)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 250, height: 250)
                .offset(x: 130, y: 250)

            VStack(spacing: 0) {
                Spacer()

                // Logo area
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 110, height: 110)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                    }

                    Text("Madhoor")
                        .font(.custom("Georgia-BoldItalic", size: 44))
                        .foregroundColor(.white)

                    Text("BOUTIQUE")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .kerning(8)

                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 60, height: 1)
                        .padding(.vertical, 4)

                    Text("Where elegance meets tradition")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Category pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["Sarees", "Lehengas", "Suits", "Sports Wear", "Bridal"], id: \.self) { cat in
                            Text(cat)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 40)

                // Action buttons
                VStack(spacing: 14) {
                    Button {
                        showLogin = true
                    } label: {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "#4A0E5E"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white)
                            .cornerRadius(14)
                    }

                    Button {
                        showRegister = true
                    } label: {
                        Text("Create Account")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.4), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 50)
            }
        }
        .sheet(isPresented: $showLogin) { LoginView() }
        .sheet(isPresented: $showRegister) { RegisterView() }
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showRegister = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#E91E8C"))
                            Text("Welcome Back")
                                .font(.custom("Georgia-Bold", size: 28))
                                .foregroundColor(Color(hex: "#1A0533"))
                            Text("Sign in to Madhoor Boutique")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 30)

                        // Form
                        VStack(spacing: 16) {
                            BoutiqueTextField(placeholder: "Email Address", text: $email,
                                             icon: "envelope", keyboardType: .emailAddress)

                            BoutiqueSecureField(placeholder: "Password", text: $password,
                                               showPassword: $showPassword)

                            if let error = authVM.errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Login button
                        Button {
                            authVM.login(email: email, password: password)
                        } label: {
                            ZStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .padding(.horizontal, 24)
                        }
                        .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)

                        Button("Forgot Password?") {}
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#9C27B0"))

                        Divider().padding(.horizontal, 24)

                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            Button("Sign Up") {
                                dismiss()
                                showRegister = true
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "#E91E8C"))
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarItems(leading: Button("Cancel") { dismiss() }
                .foregroundColor(Color(hex: "#9C27B0")))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showRegister) { RegisterView() }
        .onChange(of: authVM.isLoggedIn) { loggedIn in
            if loggedIn { dismiss() }
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var mobile = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var agreedToTerms = false
    @State private var passwordMismatch = false

    var isFormValid: Bool {
        !fullName.isEmpty && !email.isEmpty && !mobile.isEmpty &&
        !password.isEmpty && password == confirmPassword && agreedToTerms
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#E91E8C"))
                            Text("Create Account")
                                .font(.custom("Georgia-Bold", size: 28))
                                .foregroundColor(Color(hex: "#1A0533"))
                            Text("Join Madhoor Boutique family")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 14) {
                            BoutiqueTextField(placeholder: "Full Name", text: $fullName, icon: "person")
                            BoutiqueTextField(placeholder: "Email Address", text: $email,
                                             icon: "envelope", keyboardType: .emailAddress)
                            BoutiqueTextField(placeholder: "Mobile Number", text: $mobile,
                                             icon: "phone", keyboardType: .phonePad)
                            BoutiqueSecureField(placeholder: "Password", text: $password,
                                               showPassword: $showPassword)
                            BoutiqueSecureField(placeholder: "Confirm Password", text: $confirmPassword,
                                               showPassword: $showPassword)

                            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords don't match")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if let error = authVM.errorMessage {
                                Text(error).font(.system(size: 13)).foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // Terms toggle
                            HStack(alignment: .top, spacing: 10) {
                                Toggle("", isOn: $agreedToTerms)
                                    .labelsHidden()
                                    .tint(Color(hex: "#E91E8C"))
                                Text("I agree to the **Terms of Service** and **Privacy Policy**")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 24)

                        Button {
                            authVM.register(fullName: fullName, email: email,
                                            mobile: mobile, password: password)
                        } label: {
                            ZStack {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .padding(.horizontal, 24)
                        }
                        .disabled(!isFormValid || authVM.isLoading)
                        .opacity(isFormValid ? 1 : 0.6)

                        Spacer().frame(height: 30)
                    }
                }
            }
            .navigationBarItems(leading: Button("Cancel") { dismiss() }
                .foregroundColor(Color(hex: "#9C27B0")))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: authVM.isLoggedIn) { loggedIn in
            if loggedIn { dismiss() }
        }
    }
}

// MARK: - Reusable Form Fields
struct BoutiqueTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#9C27B0"))
                .frame(width: 22)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct BoutiqueSecureField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#9C27B0"))
                .frame(width: 22)
            Group {
                if showPassword {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.system(size: 15))
            .autocapitalization(.none)
            .autocorrectionDisabled()

            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
