//
//  RegisterView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var registrationSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Join VijayLaxmi Catering Services")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                    
                    // Registration Form
                    VStack(spacing: 20) {
                        // Name field
                        CustomTextField(
                            title: "Full Name",
                            placeholder: "Enter your full name",
                            text: $name
                        )
                        
                        // Email field
                        CustomTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // Phone field
                        CustomTextField(
                            title: "Phone Number",
                            placeholder: "Enter your phone number",
                            text: $phoneNumber,
                            keyboardType: .phonePad
                        )
                        
                        // Address field
                        CustomTextField(
                            title: "Address",
                            placeholder: "Enter your address",
                            text: $address,
                            isMultiline: true
                        )
                        
                        // Password field
                        CustomSecureField(
                            title: "Password",
                            placeholder: "Create a password",
                            text: $password
                        )
                        
                        // Confirm Password field
                        CustomSecureField(
                            title: "Confirm Password",
                            placeholder: "Confirm your password",
                            text: $confirmPassword
                        )
                    }
                    .padding(.horizontal)
                    
                    // Register Button
                    Button(action: registerUser) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Creating Account..." : "Create Account")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .disabled(isLoading || !isFormValid)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert(registrationSuccess ? "Success" : "Registration Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                if registrationSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && 
        !confirmPassword.isEmpty && !phoneNumber.isEmpty && !address.isEmpty
    }
    
    private func registerUser() {
        guard validateForm() else { return }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if authManager.register(
                name: name,
                email: email,
                password: password,
                phoneNumber: phoneNumber,
                address: address
            ) {
                alertMessage = "Account created successfully! You can now log in."
                registrationSuccess = true
            } else {
                alertMessage = "An account with this email already exists."
                registrationSuccess = false
            }
            showingAlert = true
            isLoading = false
        }
    }
    
    private func validateForm() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter your full name"
            showingAlert = true
            return false
        }
        
        guard isValidEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return false
        }
        
        guard phoneNumber.count >= 10 else {
            alertMessage = "Please enter a valid phone number"
            showingAlert = true
            return false
        }
        
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long"
            showingAlert = true
            return false
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return false
        }
        
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter your address"
            showingAlert = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Custom UI Components
struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            if isMultiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textInputAutocapitalization(.sentences)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .autocorrectionDisabled(keyboardType == .emailAddress)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

struct CustomSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationManager())
}