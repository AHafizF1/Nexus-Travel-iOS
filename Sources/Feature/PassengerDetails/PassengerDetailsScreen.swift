import SwiftUI
import UniformTypeIdentifiers

struct PassengerDetailsScreenRoute: View {
    @State private var viewModel: PassengerDetailsViewModel
    @State private var task: Task<Void, Never>?
    let router: Router
    let bookingFlowState: BookingFlowState

    init(viewModel: PassengerDetailsViewModel, router: Router, bookingFlowState: BookingFlowState) {
        _viewModel = State(initialValue: viewModel); self.router = router; self.bookingFlowState = bookingFlowState
    }

    var body: some View {
        PassengerDetailsScreen(viewModel: viewModel) { submit() }
            .task {
                if bookingFlowState.consumePassengerSubmissionAfterAuthentication() { submit() }
            }
            .onDisappear { task?.cancel() }
    }

    private func submit() {
        guard task == nil else { return }
        let transition = bookingFlowState.beginPassengerSubmission()
        guard transition != .unavailable else { return }
        task = Task {
            do {
                try await viewModel.submit(authenticated: transition == .submit)
            } catch is CancellationError {
                task = nil
                return
            } catch {
                task = nil
                return
            }
            route(); task = nil
        }
    }

    private func route() {
        while let event = viewModel.consumeNavigationEvent() {
            switch event {
            case .back: router.pop()
            case .authenticate: router.push(.bookingAuth(.init()))
            case let .seats(id): router.push(.seatSelection(.init(bookingId: id)))
            case .editSearch: router.popToRoot()
            }
        }
    }
}

struct PassengerDetailsScreen: View {
    @Bindable var viewModel: PassengerDetailsViewModel
    let onContinue: () -> Void
    @State private var importsDocument = false

    var body: some View {
        Form {
            if let message = viewModel.errorMessage {
                Section { Label(message, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red) }
            }
            Section("Passenger 1 · Adult") {
                Picker("Title", selection: $viewModel.form.title) {
                    ForEach(["Mr", "Ms", "Mrs", "Mx"], id: \.self) { Text($0).tag($0) }
                }
                Picker("Gender", selection: $viewModel.form.gender) {
                    ForEach(["Male", "Female", "Other"], id: \.self) { Text($0).tag($0) }
                }
                TextField("First name", text: $viewModel.form.firstName).textContentType(.givenName)
                TextField("Last name", text: $viewModel.form.lastName).textContentType(.familyName)
                dateFields("Date of birth", day: $viewModel.form.dateOfBirthDay,
                           month: $viewModel.form.dateOfBirthMonth, year: $viewModel.form.dateOfBirthYear)
                    .onChange(of: viewModel.form.dateOfBirthDay + viewModel.form.dateOfBirthMonth + viewModel.form.dateOfBirthYear) {
                        viewModel.form.dateOfBirth = viewModel.form.dateOfBirthInput().parsed
                    }
                countryPicker("Nationality", selection: $viewModel.form.nationalityCountryCode)
            }
            Section("Passport") {
                TextField("Passport number", text: $viewModel.form.passportNumber)
                    .textInputAutocapitalization(.characters)
                dateFields("Expiry date", day: $viewModel.form.passportExpiryDay,
                           month: $viewModel.form.passportExpiryMonth, year: $viewModel.form.passportExpiryYear)
                    .onChange(of: viewModel.form.passportExpiryDay + viewModel.form.passportExpiryMonth + viewModel.form.passportExpiryYear) {
                        viewModel.form.passportExpiryDate = viewModel.form.passportExpiryInput().parsed
                    }
                countryPicker("Issuing country", selection: $viewModel.form.passportIssuingCountryCode)
                Button(viewModel.form.passportDocument?.displayName ?? "Choose passport document", systemImage: "doc.badge.plus") {
                    importsDocument = true
                }
                .accessibilityHint("Choose a JPEG, PNG, or PDF up to 10 MB")
                if let error = viewModel.validation.error(for: .passportDocument) {
                    Text(error).foregroundStyle(.red)
                }
            }
            Section("Contact details") {
                TextField("Email", text: $viewModel.form.email).textContentType(.emailAddress)
                    .textInputAutocapitalization(.never).keyboardType(.emailAddress)
                HStack {
                    TextField("Code", text: $viewModel.form.countryDialCode).frame(maxWidth: 90)
                    TextField("Mobile number", text: $viewModel.form.phoneNumber).keyboardType(.phonePad)
                }
            }
            if viewModel.validation.hasErrors {
                Section("Check these details") {
                    ForEach(viewModel.validation.summaryErrors, id: \.self) { Text($0).foregroundStyle(.red) }
                }
            }
            Section {
                Button(action: onContinue) {
                    if viewModel.isSubmitting { ProgressView().frame(maxWidth: .infinity) }
                    else { Text("Continue to seats").frame(maxWidth: .infinity) }
                }.disabled(viewModel.isSubmitting)
            }
        }
        .navigationTitle("Passenger Details")
        .fileImporter(isPresented: $importsDocument, allowedContentTypes: [.pdf, .jpeg, .png]) { result in
            guard case let .success(url) = result else { return }
            viewModel.form.passportDocument = .init(
                uriString: url.absoluteString, displayName: url.lastPathComponent,
                mimeType: UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
            )
        }
    }

    private func dateFields(_ title: String, day: Binding<String>, month: Binding<String>,
                            year: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            HStack {
                TextField("DD", text: day).keyboardType(.numberPad)
                TextField("MM", text: month).keyboardType(.numberPad)
                TextField("YYYY", text: year).keyboardType(.numberPad)
            }
        }
    }

    private func countryPicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            ForEach(CountryCatalog.countries, id: \.isoCode) { country in
                Text(country.countryName).tag(country.isoCode)
            }
        }
    }
}
