import SwiftUI
import PhotosUI

// MARK: - OB-C1: Account Setup

struct ClientAccountSetupStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    @State private var showPasswordError = false

    private var isValid: Bool {
        !data.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !data.lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(data.email) &&
        data.password.count >= 8
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create your account")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Start your journey as a Fixr Client")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel("First Name")
                            TextField("Jane", text: $data.firstName)
                                .textFieldStyle(FixrTextFieldStyle())
                                .textInputAutocapitalization(.words)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel("Last Name")
                            TextField("Doe", text: $data.lastName)
                                .textFieldStyle(FixrTextFieldStyle())
                                .textInputAutocapitalization(.words)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Email Address")
                        TextField("you@example.com", text: $data.email)
                            .textFieldStyle(FixrTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Password")
                        SecureField("At least 8 characters", text: $data.password)
                            .textFieldStyle(FixrTextFieldStyle())

                        passwordStrengthBar(data.password)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                VStack(spacing: 14) {
                    FixrPrimaryButton("Continue") {
                        if isValid { onNext() }
                        else { showPasswordError = true }
                    }

                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("Incomplete Information", isPresented: $showPasswordError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please fill in all fields. Password must be at least 8 characters.")
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.fixrCaption)
            .foregroundColor(.fixrMuted)
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return value.range(of: regex, options: .regularExpression) != nil
    }

    @ViewBuilder
    private func passwordStrengthBar(_ pw: String) -> some View {
        let strength = passwordStrength(pw)
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.fixrCard).frame(height: 3)
                    Capsule().fill(strength.color)
                        .frame(width: geo.size.width * strength.fraction, height: 3)
                        .animation(.easeInOut(duration: 0.2), value: pw)
                }
            }
            .frame(height: 3)
            if !pw.isEmpty {
                Text(strength.label)
                    .font(.fixrCaption)
                    .foregroundColor(strength.color)
            }
        }
    }

    private func passwordStrength(_ pw: String) -> (color: Color, label: String, fraction: CGFloat) {
        if pw.count < 6 { return (.red, "Too short", 0.2) }
        if pw.count < 8 { return (.orange, "Weak", 0.4) }
        let hasUpper = pw.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasDigit = pw.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = pw.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        let score = [hasUpper, hasDigit, hasSpecial].filter { $0 }.count
        switch score {
        case 0: return (Color(hex: "#FBBF24"), "Fair", 0.55)
        case 1: return (.fixrPrimary, "Good", 0.75)
        default: return (Color(hex: "#22C55E"), "Strong", 1.0)
        }
    }
}

// MARK: - OB-C2: Personal Info

struct ClientPersonalInfoStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    @State private var showAgeError = false

    let provinces = ["QC", "ON", "BC", "AB", "SK", "MB", "NS", "NB", "PE", "NL", "NT", "YT", "NU"]

    private var isValid: Bool {
        data.isOf18 &&
        !data.address.trimmingCharacters(in: .whitespaces).isEmpty &&
        !data.city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !data.postalCode.trimmingCharacters(in: .whitespaces).isEmpty &&
        !data.phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Personal Information")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("You must be 18 or older to use Fixr")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date of Birth")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                        DatePicker(
                            "",
                            selection: $data.dateOfBirth,
                            in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(.fixrPrimary)
                        .padding(14)
                        .background(Color.fixrCard)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Street Address")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                        TextField("123 Rue Principale", text: $data.address)
                            .textFieldStyle(FixrTextFieldStyle())
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("City")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            TextField("Montréal", text: $data.city)
                                .textFieldStyle(FixrTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Province")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            Picker("Province", selection: $data.province) {
                                ForEach(provinces, id: \.self) { Text($0).tag($0) }
                            }
                            .tint(.fixrPrimary)
                            .padding(10)
                            .background(Color.fixrCard)
                            .cornerRadius(12)
                        }
                        .frame(width: 100)
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Postal Code")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            TextField("H1A 1A1", text: $data.postalCode)
                                .textFieldStyle(FixrTextFieldStyle())
                                .textInputAutocapitalization(.characters)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            TextField("514-555-0000", text: $data.phone)
                                .textFieldStyle(FixrTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                    }
                }
                .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    FixrPrimaryButton("Continue") {
                        if data.isOf18 { onNext() }
                        else { showAgeError = true }
                    }
                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("Age Requirement", isPresented: $showAgeError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You must be 18 years or older to create a Fixr account.")
        }
    }
}

// MARK: - OB-C3: ID Upload

struct ClientIDUploadStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    @State private var frontItem: PhotosPickerItem?
    @State private var backItem: PhotosPickerItem?
    @State private var loadFrontTask: Task<Void, Never>?
    @State private var loadBackTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ID Verification")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Upload a government-issued photo ID")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                FixrCard {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.fixrPrimary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your documents are encrypted")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.fixrText)
                            Text("AES-256 encryption at rest and in transit")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                        }
                    }
                    .padding(16)
                }
                .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    idUploadCard(
                        title: "ID Front",
                        subtitle: "Driver's licence or passport front",
                        imageData: data.idFrontImageData,
                        pickerItem: $frontItem
                    )

                    idUploadCard(
                        title: "ID Back",
                        subtitle: "Driver's licence back side",
                        imageData: data.idBackImageData,
                        pickerItem: $backItem
                    )
                }
                .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    FixrPrimaryButton("Continue") { onNext() }
                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: frontItem) { loadPhoto(item: frontItem, into: \.idFrontImageData) }
        .onChange(of: backItem) { loadPhoto(item: backItem, into: \.idBackImageData) }
        .onDisappear {
            loadFrontTask?.cancel()
            loadBackTask?.cancel()
        }
    }

    private func idUploadCard(
        title: String,
        subtitle: String,
        imageData: Data?,
        pickerItem: Binding<PhotosPickerItem?>
    ) -> some View {
        PhotosPicker(selection: pickerItem, matching: .images) {
            FixrCard {
                HStack(spacing: 14) {
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.fixrCard)
                            .frame(width: 64, height: 48)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.fixrMuted)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.fixrBody)
                            .foregroundColor(.fixrText)
                        Text(subtitle)
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                    }

                    Spacer()

                    Image(systemName: imageData != nil ? "checkmark.circle.fill" : "plus.circle.fill")
                        .foregroundColor(imageData != nil ? Color(hex: "#22C55E") : .fixrPrimary)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }

    private func loadPhoto(item: PhotosPickerItem?, into keyPath: WritableKeyPath<OnboardingData, Data?>) {
        guard let item = item else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self) {
                self.data[keyPath: keyPath] = data
            }
        }
    }
}

// MARK: - OB-C4: Review

struct ClientReviewStep: View {
    @Binding var data: OnboardingData
    var onEdit: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review Your Info")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Confirm your details before submitting")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                FixrCard {
                    VStack(spacing: 0) {
                        reviewRow(label: "Name", value: "\(data.firstName) \(data.lastName)")
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(label: "Email", value: data.email)
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(label: "Phone", value: data.phone)
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(label: "City", value: "\(data.city), \(data.province)")
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(label: "ID Upload", value: data.idFrontImageData != nil ? "Uploaded" : "Skipped")
                    }
                }
                .padding(.horizontal, 24)

                Button(action: onEdit) {
                    Label("Edit Information", systemImage: "pencil")
                        .font(.fixrBody)
                        .foregroundColor(.fixrPrimary)
                }

                Spacer().frame(height: 16)

                VStack(spacing: 14) {
                    FixrPrimaryButton("Submit Application", action: onSubmit)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
            Spacer()
            Text(value)
                .font(.fixrBody)
                .foregroundColor(.fixrText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - OB-C5: Pending

struct ClientPendingStep: View {
    var onFinish: () -> Void

    private let steps = ["Submitted", "Under Review", "ID Pending", "Approved"]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 24)

                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.fixrPrimary)

                VStack(spacing: 10) {
                    Text("Application Submitted")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("We're reviewing your information.\nThis typically takes 1-2 business days.")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                        .multilineTextAlignment(.center)
                }

                // Step tracker
                FixrCard {
                    VStack(spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(index == 0 ? Color.fixrPrimary : (index == 1 ? Color.fixrPrimary.opacity(0.3) : Color.fixrCard))
                                        .frame(width: 28, height: 28)
                                    if index == 0 {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(index == 1 ? .fixrPrimary : .fixrMuted)
                                    }
                                }

                                Text(step)
                                    .font(.fixrBody)
                                    .foregroundColor(index <= 1 ? .fixrText : .fixrMuted)

                                Spacer()

                                if index == 0 {
                                    Text("Done")
                                        .font(.fixrCaption)
                                        .foregroundColor(Color(hex: "#22C55E"))
                                } else if index == 1 {
                                    Text("In Progress")
                                        .font(.fixrCaption)
                                        .foregroundColor(.fixrOrange)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                            if index < steps.count - 1 {
                                Divider().background(Color.white.opacity(0.06))
                                    .padding(.leading, 58)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Lock banner
                FixrCard {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.fixrMuted)
                        Text("Full access unlocks after verification")
                            .font(.fixrBody)
                            .foregroundColor(.fixrMuted)
                    }
                    .padding(16)
                }
                .padding(.horizontal, 24)

                FixrPrimaryButton("Go to App", action: onFinish)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}
