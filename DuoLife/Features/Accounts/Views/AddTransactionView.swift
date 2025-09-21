import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    
    let accountId: String
    let onSave: () -> Void

    @State private var amount: String = ""
    @State private var type: TransactionType = .expense
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false

    private let firestore = FirestoreService()

    var body: some View {
        NavigationView {
            Form {
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)

                TextField("Description", text: $description)

                Picker("Type", selection: $type) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                }

                DatePicker("Date", selection: $date, displayedComponents: .date)

                Toggle("Recurring Monthly", isOn: $isRecurring)
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let tx = Transaction(
                            amount: Double(amount) ?? 0.0,
                            type: type,
                            date: date,
                            description: description,
                            isRecurring: isRecurring,
                            recurrence: isRecurring ? "monthly" : nil
                        )
                        firestore.addTransaction(to: accountId, transaction: tx) { success in
                            if success {
                                onSave()
                                dismiss()
                            }
                        }
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

