import SwiftUI

struct AddMemberView: View {
    @ObservedObject var store: MemberStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var storeName = ""
    @State private var location = ""
    @State private var phoneNumber = ""
    @State private var balance = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case storeName, location, phoneNumber, balance
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("店铺名称", text: $storeName)
                        .focused($focusedField, equals: .storeName)
                        .textContentType(.organizationName)
                        .submitLabel(.next)
                        .padding(.vertical, 8)
                    
                    TextField("店铺位置", text: $location)
                        .focused($focusedField, equals: .location)
                        .textContentType(.fullStreetAddress)
                        .submitLabel(.next)
                        .padding(.vertical, 8)
                }
                
                Section("联系方式") {
                    #if os(iOS)
                    TextField("手机号码", text: $phoneNumber)
                        .focused($focusedField, equals: .phoneNumber)
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                        .padding(.vertical, 8)
                        .onChange(of: phoneNumber) { newValue in
                            phoneNumber = String(newValue.filter { $0.isNumber }.prefix(11))
                        }
                    #else
                    TextField("手机号码", text: $phoneNumber)
                        .padding(.vertical, 8)
                    #endif
                }
                
                Section("账户信息") {
                    #if os(iOS)
                    TextField("余额", text: $balance)
                        .focused($focusedField, equals: .balance)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                        .padding(.vertical, 8)
                        .onChange(of: balance) { newValue in
                            let filtered = newValue.filter { $0.isNumber || $0 == "." }
                            if filtered != newValue {
                                balance = filtered
                            }
                            if let dotIndex = balance.firstIndex(of: ".") {
                                let decimals = balance[balance.index(after: dotIndex)...]
                                if decimals.count > 2 {
                                    balance = String(balance[...balance.index(dotIndex, offsetBy: 2)])
                                }
                            }
                        }
                    #else
                    TextField("余额", text: $balance)
                        .padding(.vertical, 8)
                    #endif
                }
                
                Section {
                    HStack(spacing: 20) {
                        Button(action: { dismiss() }) {
                            Text("取消")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.red)
                                .padding(.vertical, 4)
                        }
                        
                        Button(action: submit) {
                            Text("保存")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color(hex: "#FFFFFF"))
                                .padding(.vertical, 4)
                        }
                        .background(Color(hex: "#409EFF"))
                        .cornerRadius(4)
                        .disabled(!isValid)
                    }
                }
            }
            .frame(minWidth: 300, maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .navigationTitle("添加会员")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("完成") {
                            focusedField = nil
                        }
                    }
                }
            }
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 450)
        .interactiveDismissDisabled()
        #else
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        #endif
    }
    
    private var isValid: Bool {
        !storeName.isEmpty && 
        !location.isEmpty && 
        !phoneNumber.isEmpty && 
        !balance.isEmpty &&
        phoneNumber.count >= 11 &&
        (Double(balance) ?? 0) >= 0
    }
    
    private func submit() {
        guard isValid else {
            print("Form validation failed")
            return
        }
        
        let newMember = Member(
            storeName: storeName,
            location: location,
            balance: Double(balance) ?? 0,
            phoneNumber: phoneNumber,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        print("Submitting new member: \(newMember.storeName)")
        
        // 直接在主线程添加会员并关闭弹框
        withAnimation {
            store.addMember(newMember)
            dismiss()
        }
    }
}

#Preview {
    AddMemberView(store: MemberStore())
} 
