import SwiftUI
import PhotosUI
import Supabase

struct PostJobView: View {
    let profile: UserProfile

    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var step = 1
    private let totalSteps = 5

    // Form state
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: TradeCategory = .general
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var locationCity = ""
    @State private var locationPostal = ""
    @State private var skillLevel: SkillLevel = .any
    @State private var estimatedBudget = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var submitTask: Task<Void, Never>?
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                FixrGradientBackground()

                VStack(spacing: 0) {
                    // Progress
                    VStack(spacing: 8) {
                        HStack {
                            Text("Step \(step) of \(totalSteps)")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            Spacer()
                            Text(stepTitle)
                                .font(.fixrCaption)
                                .foregroundColor(.fixrPrimary)
                        }
                        .padding(.horizontal, 24)

                        FixrStepProgress(current: step, total: totalSteps)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    ScrollView {
                        VStack(spacing: 24) {
                            switch step {
                            case 1: step1TitleDescription
                            case 2: step2CategoryPicker
                            case 3: step3PhotoPicker
                            case 4: step4Location
                            case 5: step5Review
                            default: EmptyView()
                            }

                            if let error = errorMessage {
                                Text(error)
                                    .font(.fixrCaption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 24)
                            }

                            navigationButtons
                                .padding(.horizontal, 24)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle("Post a Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.fixrMuted)
                }
            }
        }
        .onChange(of: selectedPhotoItem) {
            Task { @MainActor in
                selectedPhotoData = try? await selectedPhotoItem?.loadTransferable(type: Data.self)
            }
        }
        .alert("Job Posted!", isPresented: $showSuccess) {
            Button("Done") { dismiss() }
        } message: {
            Text("Your job has been posted. Fixers in your area will start submitting quotes.")
        }
        .onDisappear {
            submitTask?.cancel()
        }
    }

    // MARK: - Steps

    private var step1TitleDescription: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What needs fixing?")
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)
                Text("Give your job a clear title and description")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text("Job Title")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                TextField("e.g. Fix leaking kitchen faucet", text: $title)
                    .textFieldStyle(FixrTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Description")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                TextEditor(text: $description)
                    .font(.fixrBody)
                    .foregroundColor(.fixrText)
                    .scrollContentBackground(.hidden)
                    .background(Color.fixrCard)
                    .frame(minHeight: 120)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var step2CategoryPicker: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select a Trade")
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)
                Text("Choose the type of work needed")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TradeCategory.allCases) { category in
                    categoryCard(category)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private func categoryCard(_ category: TradeCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button { selectedCategory = category } label: {
            VStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .fixrPrimary : .fixrMuted)

                Text(category.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .fixrText : .fixrMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.fixrCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.fixrPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var step3PhotoPicker: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Add a Photo")
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)
                Text("Help Fixers understand the job better (optional)")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.fixrCard)
                        .frame(height: 200)

                    if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.fixrMuted)
                            Text("Tap to add photo")
                                .font(.fixrBody)
                                .foregroundColor(.fixrMuted)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            if selectedPhotoData != nil {
                Button {
                    selectedPhotoData = nil
                    selectedPhotoItem = nil
                } label: {
                    Label("Remove photo", systemImage: "trash")
                        .font(.fixrCaption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var step4Location: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Location & Budget")
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)
                Text("Where is the job and what's your budget?")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text("City")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                TextField("Montréal", text: $locationCity)
                    .textFieldStyle(FixrTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Postal Code")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                TextField("H2X 1Y6", text: $locationPostal)
                    .textFieldStyle(FixrTextFieldStyle())
                    .textInputAutocapitalization(.characters)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Skill Level Preference")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)

                HStack(spacing: 10) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Button {
                            skillLevel = level
                        } label: {
                            Text(level.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(skillLevel == level ? .white : .fixrMuted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(skillLevel == level ? Color.fixrPrimary : Color.fixrCard)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Estimated Budget (optional)")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                HStack {
                    Text("$")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                    TextField("500", text: $estimatedBudget)
                        .keyboardType(.decimalPad)
                        .font(.fixrBody)
                        .foregroundColor(.fixrText)
                }
                .padding(14)
                .background(Color.fixrCard)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var step5Review: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Review & Submit")
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)
                Text("Confirm your job details before posting")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            FixrCard {
                VStack(spacing: 0) {
                    reviewRow("Title", title)
                    Divider().background(Color.white.opacity(0.06))
                    reviewRow("Category", selectedCategory.displayName)
                    Divider().background(Color.white.opacity(0.06))
                    reviewRow("Location", locationCity.isEmpty ? "Not set" : locationCity)
                    Divider().background(Color.white.opacity(0.06))
                    reviewRow("Skill Level", skillLevel.displayName)
                    Divider().background(Color.white.opacity(0.06))
                    reviewRow("Budget", estimatedBudget.isEmpty ? "Not specified" : "$\(estimatedBudget)")
                    Divider().background(Color.white.opacity(0.06))
                    reviewRow("Photo", selectedPhotoData != nil ? "Attached" : "None")
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private func reviewRow(_ label: String, _ value: String) -> some View {
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

    // MARK: - Navigation

    private var stepTitle: String {
        switch step {
        case 1: return "Job Details"
        case 2: return "Category"
        case 3: return "Photo"
        case 4: return "Location"
        case 5: return "Review"
        default: return ""
        }
    }

    private var navigationButtons: some View {
        VStack(spacing: 14) {
            if step == totalSteps {
                FixrPrimaryButton("Post Job", isLoading: isSubmitting, action: submitJob)
            } else {
                FixrPrimaryButton("Continue") {
                    if validateCurrentStep() {
                        withAnimation { step += 1 }
                    }
                }
            }

            if step > 1 {
                FixrBackButton {
                    withAnimation { step -= 1 }
                }
            }
        }
    }

    private func validateCurrentStep() -> Bool {
        errorMessage = nil
        switch step {
        case 1:
            guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please enter a job title."
                return false
            }
            guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please add a description."
                return false
            }
        case 4:
            guard !locationCity.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please enter your city."
                return false
            }
        default:
            break
        }
        return true
    }

    private func submitJob() {
        submitTask?.cancel()
        submitTask = Task { @MainActor in
            isSubmitting = true
            errorMessage = nil
            defer { isSubmitting = false }

            guard let userId = profile.userId else {
                errorMessage = "Unable to identify user. Please sign in again."
                return
            }

            let budget = Double(estimatedBudget)

            struct NewJobPayload: Encodable {
                let title: String
                let description: String
                let category: String
                let locationCity: String
                let locationPostal: String
                let locationProvince: String
                let skillLevelRequired: String
                let status: String
                let clientId: String
                let estimatedBudget: Double?

                enum CodingKeys: String, CodingKey {
                    case title
                    case description
                    case category
                    case locationCity = "location_city"
                    case locationPostal = "location_postal"
                    case locationProvince = "location_province"
                    case skillLevelRequired = "skill_level_required"
                    case status
                    case clientId = "client_id"
                    case estimatedBudget = "estimated_budget"
                }
            }

            let payload = NewJobPayload(
                title: title.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces),
                category: selectedCategory.rawValue,
                locationCity: locationCity,
                locationPostal: locationPostal,
                locationProvince: "QC",
                skillLevelRequired: skillLevel.rawValue,
                status: JobStatus.open.rawValue,
                clientId: userId.uuidString,
                estimatedBudget: budget
            )

            do {
                let row: JobRow = try await supabase
                    .from("jobs")
                    .insert(payload)
                    .select()
                    .single()
                    .execute()
                    .value

                let cached = row.toCachedJob()
                modelContext.insert(cached)
                try? modelContext.save()

                showSuccess = true
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .job).message
            }
        }
    }
}
