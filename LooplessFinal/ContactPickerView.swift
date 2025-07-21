//
//  ContactPickerView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//

import SwiftUI
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var showDuplicateInviteAlert: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                handleInvite(to: phoneNumber)
            }
        }

        func handleInvite(to number: String) {
            let message = "Hey! I’m using Loopless to beat screen addiction. Try it here: https://yourapp.link"

            // Clean number (remove spaces, dashes, parentheses)
            let cleanedNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

            // Load invited numbers
            var invitedNumbers = Set(UserDefaults.standard.stringArray(forKey: "invitedNumbers") ?? [])

            // If already invited, show popup and return
            if invitedNumbers.contains(cleanedNumber) {
                print("⚠️ Number already invited: \(cleanedNumber)")
                parent.showDuplicateInviteAlert = true
                return
            }

            // Save number
            invitedNumbers.insert(cleanedNumber)
            UserDefaults.standard.set(Array(invitedNumbers), forKey: "invitedNumbers")

            // Increment invite count
            var invites = UserDefaults.standard.integer(forKey: "inviteCount")
            invites += 1
            UserDefaults.standard.set(invites, forKey: "inviteCount")
            print("📨 Total unique invites: \(invites)")

            // Send SMS
            if let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "sms:\(cleanedNumber)&body=\(encoded)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

