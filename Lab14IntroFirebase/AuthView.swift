import FirebaseAuth
import FirebaseCore
import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userID: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    @State private var authStateListener: AuthStateDidChangeListenerHandle?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Lab 14: Firebase")
                    .font(.largeTitle.bold())
                    .padding(.top, 50)
                if let userID {
                    MessagesView(signOut: signOut)
                        .id(userID)
                } else {
                    Spacer()
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .accessibilityIdentifier("auth.email")
                        SecureField("Password", text: $password)
                            .accessibilityIdentifier("auth.password")
                        HStack(spacing: 20) {
                            Button("Sign In", action: signIn)
                                .buttonStyle(PrimaryButtonStyle())
                            Button("Sign Up", action: signUp)
                                .buttonStyle(SecondaryButtonStyle())
                        }
                        .disabled(isSubmitting)
                        if FirebaseApp.app() == nil {
                            Text("Agrega el GoogleService-Info.plist de App01-Lab14 para conectar Firebase.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 30)
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear(perform: checkAuthState)
        .onDisappear {
            if let authStateListener {
                Auth.auth().removeStateDidChangeListener(authStateListener)
                self.authStateListener = nil
            }
        }
    }

    private func checkAuthState() {
        guard FirebaseApp.app() != nil, authStateListener == nil else { return }
        authStateListener = Auth.auth().addStateDidChangeListener { _, user in
            if user == nil, userID != nil {
                email = ""
                password = ""
            }
            userID = user?.uid
        }
    }

    private func signIn() {
        authenticate(registering: false)
    }

    private func signUp() {
        authenticate(registering: true)
    }

    private func authenticate(registering: Bool) {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty, !password.isEmpty else {
            present("Please enter both email and password")
            return
        }
        guard address.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil else {
            present("Please enter a valid email address")
            return
        }
        guard !registering || password.count >= 6 else {
            present("Password must be at least 6 characters")
            return
        }
        guard FirebaseApp.app() != nil else {
            present("Firebase configuration is missing or does not match this app.")
            return
        }
        let submittedPassword = password
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do {
                if registering {
                    _ = try await Auth.auth().createUser(withEmail: address, password: submittedPassword)
                    present("Account created successfully!")
                } else {
                    _ = try await Auth.auth().signIn(withEmail: address, password: submittedPassword)
                    present("Sign in successful!")
                }
                password = ""
            } catch {
                present("\(registering ? "Sign up failed" : "Sign in failed"): \(error.localizedDescription)")
            }
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            present("Signed out successfully")
        } catch {
            present("Sign out failed: \(error.localizedDescription)")
        }
    }

    private func present(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding()
            .background(.blue, in: RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.blue)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 2))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SignOutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(10)
            .background(.red, in: RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
