    // MARK: - Job Titles Section (Phase 7)
    private var jobTitlesSection: some View {
        VStack(alignment: .leading, spacing: SacredUI.Spacing.standard) {
            // Header
            HStack {
                Label(PreferenceSection.jobTitles.title, systemImage: PreferenceSection.jobTitles.icon)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                if selectedJobTitles.isEmpty {
                    Text("Select 1+")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text("\(selectedJobTitles.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Select roles below or search for specific titles")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)

                TextField("Search job titles...", text: $jobTitleSearchText)
                    .focused($isSearchFieldFocused)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .accessibilityLabel("Search job titles")
                    .accessibilityHint("Enter keywords to search from 1016 occupation titles")
                    .accessibilityValue(jobTitleSearchText.isEmpty ? "Empty" : jobTitleSearchText)

                if !jobTitleSearchText.isEmpty {
                    Button(action: {
                        jobTitleSearchText = ""
                        isSearchFieldFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Clear search")
                    .accessibilityHint("Double tap to clear the search field")
                }
            }

            // Search Results or Popular Roles Grid
            if !jobTitleSearchText.isEmpty && !filteredRoles.isEmpty {
                searchAutocompleteView
            } else if !jobTitleSearchText.isEmpty {
                emptySearchResultsView
            } else {
                popularRolesGridView
            }

            // Selected Roles Chips
            if !selectedJobTitles.isEmpty {
                VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
                    Text("Your Selections (\(selectedJobTitles.count))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(Array(selectedJobTitles).sorted(), id: \.self) { title in
                        SelectedRoleChip(
                            title: title,
                            onRemove: {
                                withAnimation(.spring(response: SacredUI.Animation.springResponse,
                                                    dampingFraction: SacredUI.Animation.springDamping)) {
                                    selectedJobTitles.remove(title)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // Popular roles grid (2 columns)
    private var popularRolesGridView: some View {
        VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
            Text("Popular Roles")
                .font(.subheadline)
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(popularJobTitles, id: \.title) { role in
                    PopularRoleCard(
                        title: role.title,
                        icon: role.icon,
                        isSelected: selectedJobTitles.contains(role.title),
                        action: {
                            withAnimation(.spring(response: SacredUI.Animation.springResponse,
                                                dampingFraction: SacredUI.Animation.springDamping)) {
                                if selectedJobTitles.contains(role.title) {
                                    selectedJobTitles.remove(role.title)
                                } else {
                                    selectedJobTitles.insert(role.title)
                                }
                            }
                        }
                    )
                }
            }
        }
    }

    // Search autocomplete results
    private var searchAutocompleteView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Suggested Roles")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredRoles, id: \.id) { role in
                        Button(action: {
                            withAnimation {
                                selectedJobTitles.insert(role.title)
                                jobTitleSearchText = ""
                                isSearchFieldFocused = false
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(role.title)
                                        .font(.body)
                                        .foregroundStyle(.primary)

                                    Text(role.sector)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if selectedJobTitles.contains(role.title) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(role.title) in \(role.sector)")
                        .accessibilityHint("Double tap to add this role to your selections")

                        if role.id != filteredRoles.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }

    // Empty search results
    private var emptySearchResultsView: some View {
        VStack(spacing: SacredUI.Spacing.compact) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No roles found")
                .font(.headline)

            Text("Try different keywords or browse popular roles")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No search results. Try different keywords or browse popular roles")
    }
