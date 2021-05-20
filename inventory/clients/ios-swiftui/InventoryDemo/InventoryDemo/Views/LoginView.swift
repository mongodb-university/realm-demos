//
//  LoginView.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI
import RealmSwift

struct LoginView: View {
    @Binding var username: String

    @State private var email = ""
    @State private var password = ""
    @State private var userStore = store
    @State private var newUser = false
    
    var body: some View {
        VStack {
            Spacer()
            InputField(title: "Email", text: $email)
                .accessibility(identifier: "email_input")
            InputField(title: "Password", text: $password, showingSecureField: true)
            InputField(title: "Store", text: $userStore)
            CallToActionButton(
                title: newUser ? "Register User" : "Log In",
                action: userAction
            )
            Button(action: { newUser.toggle() }) {
                HStack {
                    CheckBox(title: "Create Account", isChecked: $newUser)
                    Spacer()
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Login", displayMode: .inline)
        .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
    }
    
    func userAction() {
        if newUser {
            signup()
        } else {
            login()
        }
    }
    
    private func signup() {
        app.emailPasswordAuth.registerUser(email: email, password: password) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                login()
            }
        }
    }
    
    private func login() {
        app.login(credentials: .emailPassword(email: email, password: password)) { _ in
            DispatchQueue.main.async {
                username = email
                store = userStore
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(username: .constant("Billy"))
    }
}
