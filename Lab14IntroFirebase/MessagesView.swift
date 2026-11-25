import SwiftUI

struct MessagesView: View {
    let userID: String
    let signOut: () -> Void
    @StateObject private var databaseService = DatabaseService()
    @State private var newMessage = ""
    @State private var isSending = false

    private var messageText: String {
        newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                    .accessibilityHidden(true)
                Text("Messages")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 4)
                Button("Sign Out", action: signOut)
                    .buttonStyle(SignOutButtonStyle())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(ChatTheme.banner)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(databaseService.messages) { message in
                            messageBubble(message)
                        }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: databaseService.messages.last?.id, initial: true) { _, lastID in
                    if let lastID {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
                .overlay {
                    if databaseService.messages.isEmpty {
                        ContentUnavailableView("No messages yet", systemImage: "bubble.left")
                            .allowsHitTesting(false)
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Type a message...", text: $newMessage)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(ChatTheme.canvas, in: Capsule())
                    .disabled(isSending)
                    .accessibilityIdentifier("messages.input")
                    .submitLabel(.send)
                    .onSubmit(send)
                Button(action: send) {
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(ChatTheme.banner, in: Circle())
                        .opacity(messageText.isEmpty || isSending ? 0.45 : 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Send")
                .disabled(messageText.isEmpty || isSending)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.background)
        }
        .background(ChatTheme.canvas.ignoresSafeArea())
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

    private func messageBubble(_ message: Message) -> some View {
        let isOwn = message.senderID == userID

        return HStack {
            if isOwn { Spacer(minLength: 32) }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.userEmail)
                    .font(.caption.weight(.semibold))
                Text(message.text)
                    .font(.body)
                Text(message.timestamp, style: .time)
                    .font(.caption2.monospacedDigit())
            }
            .foregroundStyle(isOwn ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isOwn ? AnyShapeStyle(ChatTheme.banner) : AnyShapeStyle(.background),
                in: RoundedRectangle(cornerRadius: 18)
            )

            if !isOwn { Spacer(minLength: 32) }
        }
        .id(message.id)
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
