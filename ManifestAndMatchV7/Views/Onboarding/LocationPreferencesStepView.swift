//
//  LocationPreferencesStepView.swift
//  ManifestAndMatchV7
//
//  Created: November 5, 2025
//  Purpose: Location preferences onboarding step
//  Phase: V8 - Job Source Location Implementation
//

import SwiftUI
import V7Data
import CoreData

@MainActor
struct LocationPreferencesStepView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var primaryLocation: String = ""
    @State private var additionalLocations: [String] = []
    @State private var searchRadius: Double = 50
    @State private var showingLocationInput = false
    @State private var isRemoteOnly: Bool = false

    let onComplete: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Where do you want to work?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("We'll prioritize jobs in your preferred locations")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                // Remote Toggle
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $isRemoteOnly) {
                        HStack {
                            Image(systemName: "wifi")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading) {
                                Text("Remote Only")
                                    .font(.headline)
                                Text("Only show remote positions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.purple)

                    if isRemoteOnly {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Perfect! We'll only show remote jobs")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 8)

                if !isRemoteOnly {
                    // Primary Location
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Primary Location", systemImage: "mappin.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.purple)

                        if primaryLocation.isEmpty {
                            Button(action: { showingLocationInput = true }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Add your primary location")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundStyle(.primary)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        } else {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.purple)
                                Text(primaryLocation)
                                    .fontWeight(.semibold)
                                Spacer()
                                Button("Change") {
                                    showingLocationInput = true
                                }
                                .font(.caption)
                                .foregroundStyle(.purple)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8)

                    // Search Radius
                    if !primaryLocation.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Search Distance", systemImage: "circle.dashed")
                                .font(.headline)
                                .foregroundStyle(.purple)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(Int(searchRadius)) miles")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("from \(primaryLocation)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Slider(value: $searchRadius, in: 10...100, step: 5)
                                    .tint(.purple)

                                HStack {
                                    Text("Nearby")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                    Spacer()
                                    Text("Wider Area")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8)
                    }

                    // Additional Locations
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Additional Locations (Optional)", systemImage: "mappin.and.ellipse")
                            .font(.headline)
                            .foregroundStyle(.purple)

                        if additionalLocations.isEmpty {
                            Text("Add more locations to expand your search")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        } else {
                            ForEach(additionalLocations, id: \.self) { location in
                                HStack {
                                    Image(systemName: "mappin")
                                        .foregroundStyle(.secondary)
                                    Text(location)
                                    Spacer()
                                    Button(action: {
                                        additionalLocations.removeAll { $0 == location }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }

                        Button(action: { showingLocationInput = true }) {
                            Label("Add Location", systemImage: "plus.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .foregroundStyle(.purple)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8)
                }

                // Info Box
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Don't worry!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("You can always change these settings later. Remote jobs are included by default.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                // Continue Button
                Button(action: saveAndContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canContinue ? Color.purple : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(!canContinue)
                .padding(.top, 8)
            }
            .padding()
        }
        .sheet(isPresented: $showingLocationInput) {
            LocationInputSheet(
                existingLocations: [primaryLocation] + additionalLocations,
                onSave: { location in
                    if primaryLocation.isEmpty {
                        primaryLocation = location
                    } else {
                        if !additionalLocations.contains(location) {
                            additionalLocations.append(location)
                        }
                    }
                    showingLocationInput = false
                }
            )
        }
    }

    private var canContinue: Bool {
        isRemoteOnly || !primaryLocation.isEmpty
    }

    private func saveAndContinue() {
        guard let profile = UserProfile.fetchCurrent(in: viewContext) else { return }

        // Save location preferences
        if isRemoteOnly {
            profile.primaryLocation = "Remote"
            profile.locations = ["Remote"] as NSObject
        } else {
            profile.primaryLocation = primaryLocation
            var allLocations = [primaryLocation] + additionalLocations
            profile.locations = allLocations as NSObject
        }

        profile.searchRadius = searchRadius
        profile.lastModified = Date()

        do {
            try viewContext.save()
            onComplete()
        } catch {
            print("Error saving location preferences: \(error)")
        }
    }
}

// MARK: - Location Input Sheet

struct LocationInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var locationText: String = ""

    let existingLocations: [String]
    let onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("City or location", text: $locationText)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                } header: {
                    Text("Enter Location")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Examples:")
                            .fontWeight(.semibold)
                        Text("• San Francisco, CA")
                        Text("• New York City")
                        Text("• Austin, TX")
                        Text("• Remote")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                if !existingLocations.filter({ !$0.isEmpty }).isEmpty {
                    Section("Current Locations") {
                        ForEach(existingLocations.filter({ !$0.isEmpty }), id: \.self) { location in
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.purple)
                                Text(location)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let trimmed = locationText.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmed)
                    }
                    .disabled(locationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LocationPreferencesStepView(onComplete: {})
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
