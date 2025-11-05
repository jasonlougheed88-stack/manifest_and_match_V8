//
//  LocationPreferencesView.swift
//  ManifestAndMatchV7
//
//  Created: November 5, 2025
//  Purpose: Location preferences and search radius configuration
//  Phase: V8 - Job Source Location Implementation
//

import SwiftUI
import V7Data
import CoreData

@MainActor
struct LocationPreferencesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var locations: [String] = []
    @State private var primaryLocation: String?
    @State private var searchRadius: Double = 50
    @State private var newLocation: String = ""
    @State private var showingLocationInput = false

    var body: some View {
        NavigationStack {
            Form {
                // Primary Location Section
                Section {
                    if let primary = primaryLocation {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.purple)
                            Text(primary)
                            Spacer()
                            Button("Change") {
                                showingLocationInput = true
                            }
                            .font(.caption)
                            .foregroundStyle(.purple)
                        }
                    } else {
                        Button(action: { showingLocationInput = true }) {
                            Label("Set Primary Location", systemImage: "mappin.circle")
                        }
                    }

                    Text("Jobs will be searched primarily in this location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Primary Location")
                }

                // Search Radius Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Search Radius")
                            Spacer()
                            Text("\(Int(searchRadius)) miles")
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                        }

                        Slider(value: $searchRadius, in: 10...100, step: 5)
                            .tint(.purple)
                            .onChange(of: searchRadius) { _, newValue in
                                updateSearchRadius(newValue)
                            }

                        HStack {
                            Text("10 mi")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Spacer()
                            Text("100 mi")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }

                        Text("Search for jobs within this radius of your primary location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Search Distance")
                }

                // Additional Locations Section
                Section {
                    ForEach(locations.filter { $0 != primaryLocation }, id: \.self) { location in
                        HStack {
                            Image(systemName: "mappin")
                                .foregroundStyle(.secondary)
                            Text(location)
                            Spacer()
                            Button(action: { setPrimaryLocation(location) }) {
                                Text("Set Primary")
                                    .font(.caption)
                                    .foregroundStyle(.purple)
                            }
                            Button(action: { removeLocation(location) }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    Button(action: { showingLocationInput = true }) {
                        Label("Add Location", systemName: "plus.circle")
                    }
                } header: {
                    Text("Additional Locations")
                } footer: {
                    Text("Add multiple locations to expand your job search")
                }

                // Remote Preference Info
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("Remote jobs are always included in search results regardless of location settings")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Location Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingLocationInput) {
                LocationInputView(onSave: { location in
                    addLocation(location)
                    showingLocationInput = false
                })
            }
            .onAppear {
                loadLocations()
            }
        }
    }

    // MARK: - Data Management

    private func loadLocations() {
        guard let profile = UserProfile.fetchCurrent(in: viewContext) else { return }

        // Load locations array
        if let savedLocations = profile.locations as? [String] {
            locations = savedLocations
        }

        // Load primary location
        primaryLocation = profile.primaryLocation

        // Load search radius
        searchRadius = profile.searchRadius
    }

    private func addLocation(_ location: String) {
        guard !location.isEmpty else { return }
        guard !locations.contains(location) else { return }

        locations.append(location)

        // If this is the first location, set it as primary
        if primaryLocation == nil {
            primaryLocation = location
        }

        saveLocations()
    }

    private func removeLocation(_ location: String) {
        locations.removeAll { $0 == location }

        // If we removed the primary location, set first remaining as primary
        if primaryLocation == location {
            primaryLocation = locations.first
        }

        saveLocations()
    }

    private func setPrimaryLocation(_ location: String) {
        primaryLocation = location
        saveLocations()
    }

    private func updateSearchRadius(_ radius: Double) {
        guard let profile = UserProfile.fetchCurrent(in: viewContext) else { return }
        profile.setSearchRadius(radius)

        do {
            try viewContext.save()
        } catch {
            print("Error saving search radius: \(error)")
        }
    }

    private func saveLocations() {
        guard let profile = UserProfile.fetchCurrent(in: viewContext) else { return }

        profile.locations = locations as NSObject
        profile.primaryLocation = primaryLocation
        profile.lastModified = Date()

        do {
            try viewContext.save()
        } catch {
            print("Error saving locations: \(error)")
        }
    }
}

// MARK: - Location Input View

struct LocationInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var locationText: String = ""
    let onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter city or location", text: $locationText)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()

                    Text("Examples: San Francisco, CA • New York City • Remote • Austin, TX")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Location")
                }

                Section {
                    Button("Add Location") {
                        onSave(locationText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    .disabled(locationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .frame(maxWidth: .infinity, alignment: .center)
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
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LocationPreferencesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
