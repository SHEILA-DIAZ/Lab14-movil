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
            Group {
                if let userID {
                    MessagesView(userID: userID, signOut: signOut)
                        .id(userID)
                } else {
                    signInForm
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

    private var signInForm: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                    Text("Lab 14: Firebase")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text("Sign in to join the conversation.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .padding(.horizontal, 16)
                .background(ChatTheme.banner, in: RoundedRectangle(cornerRadius: 30))

                VStack(alignment: .leading, spacing: 14) {
                    LabeledContent {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .accessibilityIdentifier("auth.email")
                    } label: {
                        Image(systemName: "envelope").accessibilityHidden(true)
                    }
                    .modifier(ChatFieldStyle())

                    LabeledContent {
                        SecureField("Password", text: $password)
                            .accessibilityIdentifier("auth.password")
                    } label: {
                        Image(systemName: "lock").accessibilityHidden(true)
                    }
                    .modifier(ChatFieldStyle())

                    Button("Sign In", action: signIn)
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isSubmitting)
                    Button("Sign Up", action: signUp)
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(isSubmitting)

                    if FirebaseApp.app() == nil {
                        Text("Agrega el GoogleService-Info.plist de App01-Lab14 para conectar Firebase.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 26))
                .overlay {
                    RoundedRectangle(cornerRadius: 26)
                        .strokeBorder(.indigo.opacity(0.18))
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: 460)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(ChatTheme.canvas.ignoresSafeArea())
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
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(ChatTheme.banner, in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.indigo)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SignOutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 13)
            .frame(minHeight: 44)
            .background(.white.opacity(0.19), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

enum ChatTheme {
    static let banner = LinearGradient(
        colors: [Color(red: 0.20, green: 0.16, blue: 0.66), Color(red: 0.57, green: 0.15, blue: 0.58)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let canvas = Color.indigo.opacity(0.07)
}

private struct ChatFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.indigo)
            .multilineTextAlignment(.leading)
            .padding(14)
            .background(ChatTheme.canvas, in: RoundedRectangle(cornerRadius: 14))
    }
}
