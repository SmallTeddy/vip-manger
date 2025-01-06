import SwiftUI

struct EditMemberView: View {
    @ObservedObject var store: MemberStore
    let member: Member
    @Environment(\.dismiss) private var dismiss
    
    @State private var storeName: String
    @State private var location: String
    @State private var phoneNumber: String
    @State private var balance: String
    
    init(store: MemberStore, member: Member) {
        self.store = store
        self.member = member
        _storeName = State(initialValue: member.storeName)
        _location = State(initialValue: member.location)
        _phoneNumber = State(initialValue: member.phoneNumber)
        _balance = State(initialValue: String(format: "%.2f", member.balance))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("店铺名称", text: $storeName)
                        .textContentType(.organizationName)
                        .padding(.vertical, 8)
                    
                    TextField("店铺位置", text: $location)
                        .textContentType(.fullStreetAddress)
                        .padding(.vertical, 8)
                }
                
                Section("联系方式") {
                    #if os(iOS)
                    TextField("手机号码", text: $phoneNumber)
                        .keyboardType(.numberPad)
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
                        .keyboardType(.decimalPad)
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
                            Text("更新")
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
            .navigationTitle("编辑会员")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
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
        guard isValid else { return }
        
        let updatedMember = Member(
            id: member.id,
            storeName: storeName,
            location: location,
            balance: Double(balance) ?? 0,
            phoneNumber: phoneNumber,
            createdAt: member.createdAt,
            updatedAt: Date()
        )
        
        withAnimation {
            store.updateMember(updatedMember)
            dismiss()
        }
    }
} 
