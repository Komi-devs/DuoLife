import SwiftUI

struct PasswordMasterView: View {
    @EnvironmentObject private var masterManager: MasterPasswordManager
    @StateObject private var vm: PasswordMasterViewModel

    init(viewModel: PasswordMasterViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(vm.isFirstTime ? "Set Master Password" : "Enter Master Password")
                .font(.title)

            SecureField("Master Password", text: $vm.masterPassword)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button(vm.isFirstTime ? "Set Password" : "Unlock") {
                vm.submitPassword(masterManager: masterManager)
            }
            .padding()
            .buttonStyle(.borderedProminent)

            if vm.showError {
                Text("Wrong password, try again.")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
