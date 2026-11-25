import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let userEmail: String
    let senderID: String?
    let timestamp: Date

    init?(document: QueryDocumentSnapshot) {
        let data = document.data(with: .estimate)
        guard let text = data["text"] as? String,
              let userEmail = data["userEmail"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else { return nil }
        id = document.documentID
        self.text = text
        self.userEmail = userEmail
        senderID = data["uid"] as? String
        self.timestamp = timestamp.dateValue()
    }
}

@MainActor
final class DatabaseService: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var errorMessage: String?
    private var listener: ListenerRegistration?
    private var subscription = UUID()

    private var collection: CollectionReference {
        Firestore.firestore().collection("messages")
    }

    func startListening() {
        guard listener == nil else { return }
        let subscription = UUID()
        self.subscription = subscription
        listener = collection.order(by: "timestamp").limit(toLast: 100)
            .addSnapshotListener { [weak self] snapshot, error in
                let messages = snapshot?.documents.compactMap(Message.init(document:))
                DispatchQueue.main.async {
                    guard let self, self.subscription == subscription else { return }
                    if let error {
                        self.stopListening()
                        self.errorMessage = error.localizedDescription
                    } else if let messages {
                        self.messages = messages
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        subscription = UUID()
        messages = []
    }

    func addMessage(text: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw MessageError.sessionRequired
        }
        try await collection.document().setData([
            "text": text,
            "userEmail": email,
            "uid": user.uid,
            "timestamp": FieldValue.serverTimestamp()
        ])
    }

    private enum MessageError: LocalizedError {
        case sessionRequired

        var errorDescription: String? {
            "Sign in before sending messages."
        }
    }
}
