import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Foundation
import Combine

struct Message: Identifiable, Codable {
    let id: String
    let text: String
    let userEmail: String
    let timestamp: Date

    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any],
              let text = value["text"] as? String,
              let userEmail = value["userEmail"] as? String,
              let timestamp = value["timestamp"] as? Double else { return nil }
        id = snapshot.key
        self.text = text
        self.userEmail = userEmail
        self.timestamp = Date(timeIntervalSince1970: timestamp / 1_000)
    }
}

@MainActor
final class DatabaseService: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var errorMessage: String?
    private var query: DatabaseQuery?
    private var observer: DatabaseHandle?
    private var subscription = UUID()

    private var reference: DatabaseReference? {
        guard let url = FirebaseApp.app()?.options.databaseURL, !url.isEmpty else { return nil }
        return Database.database(url: url).reference().child("messages")
    }

    func startListening() {
        guard observer == nil else { return }
        guard let reference else {
            errorMessage = "GoogleService-Info.plist must include the Realtime Database URL."
            return
        }
        let subscription = UUID()
        self.subscription = subscription
        let query = reference.queryOrdered(byChild: "timestamp").queryLimited(toLast: 100)
        self.query = query
        observer = query.observe(.value, with: { [weak self] snapshot in
            let messages = snapshot.children.compactMap { child -> Message? in
                guard let child = child as? DataSnapshot else { return nil }
                return Message(snapshot: child)
            }
            DispatchQueue.main.async {
                guard let self, self.subscription == subscription else { return }
                self.messages = messages
            }
        }, withCancel: { [weak self] error in
            DispatchQueue.main.async {
                guard let self, self.subscription == subscription else { return }
                self.stopListening()
                self.errorMessage = error.localizedDescription
            }
        })
    }

    func stopListening() {
        if let observer {
            query?.removeObserver(withHandle: observer)
        }
        subscription = UUID()
        observer = nil
        query = nil
        messages = []
    }

    func addMessage(text: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw MessageError.sessionRequired
        }
        guard let reference else { throw MessageError.databaseUnavailable }
        try await reference.childByAutoId().setValue([
            "text": text,
            "userEmail": email,
            "uid": user.uid,
            "timestamp": ServerValue.timestamp()
        ])
    }

    private enum MessageError: LocalizedError {
        case sessionRequired
        case databaseUnavailable

        var errorDescription: String? {
            switch self {
            case .sessionRequired: "Sign in before sending messages."
            case .databaseUnavailable: "The Realtime Database URL is missing."
            }
        }
    }
}
