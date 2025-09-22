import SwiftUI

struct PasswordMasterView: View {
    @StateObject private var viewModel: PasswordMasterViewModel

    init(masterManager: MasterPasswordManager) {
        _viewModel = StateObject(wrappedValue: PasswordMasterViewModel(masterManager: masterManager))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.isFirstTime ? "Set Master Password" : "Enter Master Password")
                .font(.title)

            SecureField("Master Password", text: $viewModel.inputPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button(viewModel.isFirstTime ? "Set Password" : "Unlock") {
                viewModel.submit()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            if viewModel.showError {
                Text("Wrong password, try again.")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
