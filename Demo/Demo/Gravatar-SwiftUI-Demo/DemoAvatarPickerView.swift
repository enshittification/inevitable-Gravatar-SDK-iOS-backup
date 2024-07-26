import SwiftUI
@testable import GravatarUI

struct DemoAvatarPickerView: View {
    
    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickerToken") private var token: String = ""
    @State private var isSecure: Bool = true
    
    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                HStack {
                    tokenField()
                        .font(.callout)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                Divider()
                Button("Tap to open the Avatar Picker") {
                    isPresentingPicker.toggle()
                }
                .avatarPickerSheet(isPresented: $isPresentingPicker,
                                   email: email,
                                   authToken: token)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    func tokenField() -> some View {
        if isSecure {
            SecureField("Token", text: $token)
        } else {
            TextField("Token", text: $token)
        }
    }
}

#Preview {
    DemoAvatarPickerView()
}