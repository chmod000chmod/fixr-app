import SwiftUI
import PhotosUI

// MARK: - OB-F1: Fixer Account Setup

struct FixerAccountSetupStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    @State private var showError = false

    private var isValid: Bool {
        !data.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !data.lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(data.email) &&
        !data.phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        data.password.count >= 8
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fixer Account")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Join Quebec's top tradespeople network")
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
                            TextField("Jean", text: $data.firstName)
                                .textFieldStyle(FixrTextFieldStyle())
                                .textInputAutocapitalization(.words)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel("Last Name")
                            TextField("Tremblay", text: $data.lastName)
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
                        fieldLabel("Phone Number")
                        TextField("514-555-0000", text: $data.phone)
                            .textFieldStyle(FixrTextFieldStyle())
                            .keyboardType(.phonePad)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("Password")
                        SecureField("At least 8 characters", text: $data.password)
                            .textFieldStyle(FixrTextFieldStyle())
                    }
                }
                .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    FixrOrangeButton("Continue") {
                        if isValid { onNext() }
                        else { showError = true }
                    }
                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("Incomplete", isPresented: $showError) {
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
}

// MARK: - OB-F2: Trade Selection

struct FixerTradeSelectionStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    @State private var showError = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Specialties")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Select all trades you can perform")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(TradeCategory.allCases) { trade in
                        tradeCategoryCard(trade)
                    }
                }
                .padding(.horizontal, 24)

                if !data.selectedTrades.isEmpty {
                    HStack {
                        Text("\(data.selectedTrades.count) selected")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }

                VStack(spacing: 14) {
                    FixrOrangeButton("Continue") {
                        if data.selectedTrades.isEmpty { showError = true }
                        else { onNext() }
                    }
                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("Select a Trade", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please select at least one trade specialty to continue.")
        }
    }

    private func tradeCategoryCard(_ trade: TradeCategory) -> some View {
        let isSelected = data.selectedTrades.contains(trade)

        return Button {
            if isSelected {
                data.selectedTrades.remove(trade)
            } else {
                data.selectedTrades.insert(trade)
            }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: trade.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .fixrOrange : .fixrMuted)

                Text(trade.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .fixrText : .fixrMuted)
                    .multilineTextAlignment(.center)

                Text(trade.description)
                    .font(.system(size: 10))
                    .foregroundColor(.fixrMuted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .background(Color.fixrCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.fixrOrange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - OB-F3: Experience

struct FixerExperienceStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    let levels: [(key: String, label: String, description: String)] = [
        ("apprentice", "Apprentice", "Learning the trade, under supervision"),
        ("junior", "Junior", "1-3 years, independent on standard jobs"),
        ("senior", "Senior", "3+ years, handles complex projects"),
        ("master", "Master", "Expert with formal certifications")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Experience")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("This helps us match you with the right jobs")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                VStack(spacing: 10) {
                    ForEach(levels, id: \.key) { level in
                        experienceLevelCard(level)
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Certifications (optional)")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                    TextField("e.g. C-Gas, HVAC Certification...", text: $data.certifications)
                        .textFieldStyle(FixrTextFieldStyle())
                }
                .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    FixrOrangeButton("Continue", action: onNext)
                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func experienceLevelCard(_ level: (key: String, label: String, description: String)) -> some View {
        let isSelected = data.experienceLevel == level.key

        return Button {
            data.experienceLevel = level.key
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.label)
                        .font(.fixrHeading)
                        .foregroundColor(.fixrText)
                    Text(level.description)
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.fixrOrange)
                        .font(.system(size: 20))
                }
            }
            .padding(16)
            .background(Color.fixrCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.fixrOrange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - OB-F5: RBQ Licence Entry

struct FixerLicenceStep: View {
    @Binding var data: OnboardingData
    var onBack: () -> Void
    var onNext: () -> Void

    @State private var showFormatError = false
    let provinces = ["QC", "ON", "BC", "AB", "SK", "MB", "NS", "NB", "PE", "NL"]

    private var rbqFormatValid: Bool {
        guard !data.hasNoRbqLicence else { return true }
        if data.rbqLicence.isEmpty { return true }
        let regex = #"^\d{4}-\d{4}-\d{2}$"#
        return data.rbqLicence.range(of: regex, options: .regularExpression) != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Licences & Coverage")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Required for regulated work in Quebec")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // RBQ licence section
                VStack(spacing: 12) {
                    RBQLicenceView(licenceNumber: $data.rbqLicence)

                    if !rbqFormatValid {
                        Text("Format must be XXXX-XXXX-XX (e.g. 1234-5678-01)")
                            .font(.fixrCaption)
                            .foregroundColor(.red)
                    }

                    Toggle(isOn: $data.hasNoRbqLicence) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I don't have an RBQ licence")
                                .font(.fixrBody)
                                .foregroundColor(.fixrText)
                            Text("Junior pathway — limited to non-regulated jobs")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                        }
                    }
                    .tint(.fixrOrange)
                    .padding(16)
                    .background(Color.fixrCard)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.horizontal, 24)

                // Service area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Service Radius")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)

                    VStack(spacing: 6) {
                        Slider(value: Binding(
                            get: { Double(data.serviceRadiusKm) },
                            set: { data.serviceRadiusKm = Int($0) }
                        ), in: 5...100, step: 5)
                        .tint(.fixrOrange)

                        HStack {
                            Text("5 km")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            Spacer()
                            Text("\(data.serviceRadiusKm) km")
                                .font(.fixrBody)
                                .foregroundColor(.fixrText)
                            Spacer()
                            Text("100 km")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Insurance
                Toggle(isOn: $data.hasInsurance) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("I have liability insurance")
                            .font(.fixrBody)
                            .foregroundColor(.fixrText)
                        Text("Recommended for RBQ-regulated work")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                    }
                }
                .tint(.fixrOrange)
                .padding(16)
                .background(Color.fixrCard)
                .cornerRadius(12)
                .padding(.horizontal, 24)

                VStack(spacing: 14) {
                    FixrOrangeButton("Continue") {
                        if rbqFormatValid { onNext() }
                        else { showFormatError = true }
                    }
                    FixrBackButton(action: onBack)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("Invalid Format", isPresented: $showFormatError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("RBQ licence must be in format XXXX-XXXX-XX. Example: 1234-5678-01")
        }
    }
}

// MARK: - OB-F6: Fixer Review

struct FixerReviewStep: View {
    @Binding var data: OnboardingData
    var onEdit: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review Your Profile")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Confirm all details before submitting")
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
                        reviewRow(label: "Level", value: data.experienceLevel.capitalized)
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(
                            label: "Trades",
                            value: data.selectedTrades.map(\.displayName).joined(separator: ", ")
                        )
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(
                            label: "RBQ",
                            value: data.hasNoRbqLicence ? "Junior pathway" : (data.rbqLicence.isEmpty ? "Not provided" : data.rbqLicence)
                        )
                        Divider().background(Color.white.opacity(0.06))
                        reviewRow(label: "Service Area", value: "\(data.serviceRadiusKm) km")
                    }
                }
                .padding(.horizontal, 24)

                Button(action: onEdit) {
                    Label("Edit Information", systemImage: "pencil")
                        .font(.fixrBody)
                        .foregroundColor(.fixrOrange)
                }

                VStack(spacing: 14) {
                    FixrOrangeButton("Submit Application", action: onSubmit)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
            Spacer()
            Text(value)
                .font(.fixrBody)
                .foregroundColor(.fixrText)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - OB-F7: Fixer Pending

struct FixerPendingStep: View {
    var onFinish: () -> Void

    private let steps = [
        ("Submitted", "checkmark.circle.fill", true),
        ("ID Verified", "person.badge.shield.checkmark.fill", false),
        ("RBQ Check", "building.columns.fill", false),
        ("Activated", "bolt.circle.fill", false)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 24)

                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.fixrOrange)

                VStack(spacing: 10) {
                    Text("Application Received!")
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    Text("Your Fixer profile is under review.\nWe'll notify you when it's approved.")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                        .multilineTextAlignment(.center)
                }

                // 4-step tracker
                FixrCard {
                    VStack(spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(step.2 ? Color.fixrOrange : (index == 1 ? Color.fixrOrange.opacity(0.3) : Color.fixrCard))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: step.1)
                                        .font(.system(size: 14))
                                        .foregroundColor(step.2 ? .white : (index == 1 ? .fixrOrange : .fixrMuted))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(step.0)
                                        .font(.fixrBody)
                                        .foregroundColor(step.2 || index == 1 ? .fixrText : .fixrMuted)
                                    if index == 1 {
                                        Text("In progress")
                                            .font(.fixrCaption)
                                            .foregroundColor(.fixrOrange)
                                    }
                                }

                                Spacer()

                                if step.2 {
                                    Text("Done")
                                        .font(.fixrCaption)
                                        .foregroundColor(Color(hex: "#22C55E"))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                            if index < steps.count - 1 {
                                Divider().background(Color.white.opacity(0.06))
                                    .padding(.leading, 62)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Info bullets
                VStack(alignment: .leading, spacing: 12) {
                    FixrBullet(text: "RBQ licence verification takes 1-3 business days", color: .fixrOrange)
                    FixrBullet(text: "You'll receive an email when activated", color: .fixrOrange)
                    FixrBullet(text: "You can browse jobs while you wait", color: .fixrOrange)
                }
                .padding(.horizontal, 24)

                FixrOrangeButton("Browse the App", action: onFinish)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}
