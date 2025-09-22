import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject var masterManager: MasterPasswordManager
    
    @ObservedObject var passwordVM: PasswordMasterViewModel

    var body: some View {
        NavigationStack {
            Form {
                // ----- Update Master Password -----
                Section(header: Text("Change Master Password")) {
                    SecureField("Current Master Password", text: $vm.oldPassword)
                    SecureField("New Master Password", text: $vm.newPassword)
                    SecureField("Confirm New Password", text: $vm.confirmPassword)

                    Button("Update Password") {
                        vm.updateMasterPassword(masterManager: masterManager)
                    }
                    .buttonStyle(.borderedProminent)
                }

                // ----- Reset Master Password -----
                Section(header: Text("Reset Master Password")) {
                    Text("Type \"admin\" to reset and KEEP data, or \"confirm\" to reset and DELETE all data.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    TextField("Enter reset token", text: $vm.resetToken)

                    Button("Reset Master Password") {
                        vm.resetMasterPassword(masterManager: masterManager, passwordVM: passwordVM)
                    }
                    .tint(.red)
                }

                // ----- Feedback -----
                if let msg = vm.message {
                    Section {
                        Text(msg)
                            .foregroundColor(msg.contains("removed") ? .orange :
                                             msg.contains("updated") ? .green : .red)
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
