//
//  AuthenticationManager.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let usersKey = "RegisteredUsers"
    private let currentUserKey = "CurrentUser"
    
    init() {
        loadCurrentUser()
    }
    
    // MARK: - Registration
    func register(name: String, email: String, password: String, phoneNumber: String, address: String) -> Bool {
        // Check if user already exists
        if isUserRegistered(email: email) {
            return false
        }
        
        let newUser = User(name: name, email: email, phoneNumber: phoneNumber, address: address)
        
        // Save user credentials (In a real app, use Keychain for passwords)
        var registeredUsers = getRegisteredUsers()
        registeredUsers[email] = ["user": newUser, "password": password]
        saveRegisteredUsers(registeredUsers)
        
        return true
    }
    
    // MARK: - Login
    func login(email: String, password: String) -> Bool {
        let registeredUsers = getRegisteredUsers()
        
        guard let userData = registeredUsers[email],
              let savedPassword = userData["password"] as? String,
              let user = userData["user"] as? User,
              savedPassword == password else {
            return false
        }
        
        currentUser = user
        isLoggedIn = true
        saveCurrentUser(user)
        
        return true
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        isLoggedIn = false
        userDefaults.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - Helper Methods
    private func isUserRegistered(email: String) -> Bool {
        let registeredUsers = getRegisteredUsers()
        return registeredUsers[email] != nil
    }
    
    private func getRegisteredUsers() -> [String: [String: Any]] {
        guard let data = userDefaults.data(forKey: usersKey),
              let users = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return [:]
        }
        return users
    }
    
    private func saveRegisteredUsers(_ users: [String: [String: Any]]) {
        guard let data = try? JSONSerialization.data(withJSONObject: users) else { return }
        userDefaults.set(data, forKey: usersKey)
    }
    
    private func saveCurrentUser(_ user: User) {
        guard let encoded = try? JSONEncoder().encode(user) else { return }
        userDefaults.set(encoded, forKey: currentUserKey)
    }
    
    private func loadCurrentUser() {
        guard let data = userDefaults.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        
        currentUser = user
        isLoggedIn = true
    }
}