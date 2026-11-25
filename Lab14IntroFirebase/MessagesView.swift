import SwiftUI

struct MessagesView: View {
    let signOut: () -> Void
    @StateObject private var databaseService = DatabaseService()
    @State private var newMessage = ""
    @State private var isSending = false

    private var messageText: String {
        newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Messages")
                    .font(.title.bold())
                Spacer()
                Button("Sign Out", action: signOut)
                    .buttonStyle(SignOutButtonStyle())
            }
            .padding()

            List(databaseService.messages) { message in
                VStack(alignment: .leading, spacing: 5) {
                    Text(message.text)
                    HStack {
                        Text(message.userEmail)
                        Spacer()
                        Text(message.timestamp, style: .time)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
            .overlay {
                if databaseService.messages.isEmpty {
                    ContentUnavailableView("No messages yet", systemImage: "bubble.left")
                        .allowsHitTesting(false)
                }
            }

            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isSending)
                    .accessibilityIdentifier("messages.input")
                    .submitLabel(.send)
                    .onSubmit(send)
                Button("Send", action: send)
                    .disabled(messageText.isEmpty || isSending)
            }
            .padding()
        }
        .onAppear(perform: databaseService.startListening)
        .onDisappear(perform: databaseService.stopListening)
        .alert("Messages", isPresented: Binding(
            get: { databaseService.errorMessage != nil },
            set: { if !$0 { databaseService.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(databaseService.errorMessage ?? "")
        }
    }

    private func send() {
        let text = messageText
        guard !text.isEmpty, !isSending else { return }
        guard text.utf16.count <= 500 else {
            databaseService.errorMessage = "Messages can contain up to 500 characters."
            return
        }
        isSending = true
        Task {
            defer { isSending = false }
            do {
                try await databaseService.addMessage(text: text)
                newMessage = ""
            } catch {
                databaseService.errorMessage = error.localizedDescription
            }
        }
    }
}
