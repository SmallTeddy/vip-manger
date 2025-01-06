import SwiftUI

struct MemberCard: View {
    let store: MemberStore
    let member: Member
    let onDelete: () -> Void
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(member.storeName)
                        .font(.headline)
                    Text("位置: \(member.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("手机: \(member.phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("¥\(String(format: "%.2f", member.balance))")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMemberView(store: store, member: member)
        }
    }
} 
