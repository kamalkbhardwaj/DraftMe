//
//  CanvasView.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import SwiftUI

struct CanvasView: View {
    
    @State var model: CanvasViewModel
    enum Mode: String, CaseIterable, Identifiable { case edit, styled, ats; var id: String { rawValue } }
    @State private var mode: Mode = .edit
    @State private var newSkill: String = ""
    @State private var newCert: String = ""
    
    init(model: CanvasViewModel) {
        self.model = model
    }
    
    var body: some View {
        contentView
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Picker("Mode", selection: $mode) {
                        Text("Edit").tag(Mode.edit)
                        Text("Styled").tag(Mode.styled)
                        Text("ATS").tag(Mode.ats)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 260)

                    Button("Export PDF") { exportResume() }
                        .foregroundStyle(Color.primary)
                }
            }
    }
    
    private var contentView: some View {
            VStack(spacing: 0) {
                header
                Divider()
                content
            }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.resume.basics.fullName)
                    .font(.title).bold()
                Text(model.resume.basics.title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(model.resume.basics.email)
                Text(model.resume.basics.phone)
                Text(model.resume.basics.location)
                Text(model.resume.basics.website)
                Text(model.resume.basics.linkedin)
                Text(model.resume.basics.github)
            }
            .font(.footnote)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Resume header with contact information")
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .edit: editForm
        case .styled: styledPreview
        case .ats: atsPreview
        }
    }

    private var editForm: some View {
        Form {
            Section("Basics") {
                TextField("Full Name", text: $model.resume.basics.fullName)
                TextField("Title", text: $model.resume.basics.title)
                TextField("Email", text: $model.resume.basics.email)
                TextField("Phone", text: $model.resume.basics.phone)
                TextField("Location", text: $model.resume.basics.location)
                TextField("Website", text: $model.resume.basics.website)
                TextField("LinkedIn", text: $model.resume.basics.linkedin)
                TextField("GitHub", text: $model.resume.basics.github)
            }

            Section("Professional Summary") {
                TextEditor(text: $model.resume.summary)
                    .frame(minHeight: 120)
            }

            Section("Experience") {
                ForEach($model.resume.experience) { $exp in
                    VStack(alignment: .leading) {
                        TextField("Role", text: $exp.role)
                        TextField("Company", text: $exp.company)
                        TextField("Location", text: $exp.location)
                        HStack {
                            TextField("Start Date", text: $exp.startDate)
                            Text("–")
                            TextField("End Date", text: $exp.endDate)
                        }
                        ForEach(exp.bullets.indices, id: \.self) { i in
                            TextField("Bullet #\(i+1)", text: Binding(
                                get: { exp.bullets[i] },
                                set: { exp.bullets[i] = $0 }
                            ))
                        }
                    }
                }
                .onDelete(perform: model.removeExperience)
                Button("Add Experience") { model.addExperience() }
            }

            Section("Skills") {
                HStack {
                    TextField("Add skill", text: $newSkill)
                    Button("Add") { model.addSkill(newSkill); newSkill = "" }
                        .disabled(newSkill.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                if !model.resume.skills.isEmpty {
                    ForEach(Array(model.resume.skills.enumerated()), id: \.offset) { idx, skill in
                        Text(skill)
                    }
                    .onDelete(perform: model.removeSkill)
                }
            }

            Section("Certifications") {
                HStack {
                    TextField("Add certification", text: $newCert)
                    Button("Add") { model.addCertification(newCert); newCert = "" }
                        .disabled(newCert.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                if !model.resume.certifications.isEmpty {
                    ForEach(Array(model.resume.certifications.enumerated()), id: \.offset) { idx, cert in
                        Text(cert)
                    }
                    .onDelete(perform: model.removeCertification)
                }
            }

            Section("Education") {
                ForEach($model.resume.education) { $edu in
                    VStack(alignment: .leading) {
                        TextField("Institution", text: $edu.institution)
                        TextField("Degree", text: $edu.degree)
                        HStack {
                            TextField("Start", text: $edu.startDate)
                            Text("–")
                            TextField("End", text: $edu.endDate)
                        }
                    }
                }
            }
        }
    }

    private var atsPreview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Professional Summary")
                Text(model.resume.summary)
                    .font(.body)
                Divider()

                sectionHeader("Experience")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.resume.experience) { exp in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(exp.role) – \(exp.company)").bold()
                            Text("\(exp.location) • \(exp.startDate) – \(exp.endDate)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(exp.bullets, id: \.self) { bullet in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                        Text(bullet)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Divider()

                sectionHeader("Skills")
                Text(model.resume.skills.joined(separator: ", "))
                Divider()

                sectionHeader("Certifications")
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(model.resume.certifications, id: \.self) { cert in
                        Text("• \(cert)")
                    }
                }
                Divider()

                sectionHeader("Education")
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.resume.education) { edu in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(edu.institution).bold()
                            Text("\(edu.degree) • \(edu.startDate) – \(edu.endDate)")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
        }
        .accessibilityElement(children: .combine)
    }

    private var styledPreview: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 0) {
                // Left rail
                VStack(alignment: .leading, spacing: 16) {
                    // Avatar placeholder / color block
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [.blue.opacity(0.85), .blue.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 120)

                    // Contact
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CONTACT").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                        Group {
                            Text(model.resume.basics.email)
                            Text(model.resume.basics.phone)
                            Text(model.resume.basics.location)
                            if !model.resume.basics.website.isEmpty { Text(model.resume.basics.website) }
                            if !model.resume.basics.linkedin.isEmpty { Text(model.resume.basics.linkedin) }
                            if !model.resume.basics.github.isEmpty { Text(model.resume.basics.github) }
                        }.font(.footnote)
                    }

                    // Skills
                    if !model.resume.skills.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SKILLS").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(model.resume.skills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.footnote)
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                    }

                    // Certifications
                    if !model.resume.certifications.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CERTIFICATIONS").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                            ForEach(model.resume.certifications, id: \.self) { cert in
                                Text("• \(cert)").font(.footnote)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: 220)
                .padding(16)
                .background(Color.gray.opacity(0.08))

                // Right main
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.resume.basics.fullName).font(.title2.bold())
                        Text(model.resume.basics.title).font(.headline).foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PROFESSIONAL SUMMARY").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                        Text(model.resume.summary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXPERIENCE").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                        ForEach(model.resume.experience) { exp in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack { Text(exp.role).bold(); Text("•"); Text(exp.company).bold() }
                                Text("\(exp.location) • \(exp.startDate) – \(exp.endDate)").font(.footnote).foregroundStyle(.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(exp.bullets, id: \.self) { bullet in
                                        HStack(alignment: .top, spacing: 6) { Text("•"); Text(bullet) }
                                    }
                                }
                            }.padding(.vertical, 4)
                        }
                    }

                    if !model.resume.education.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EDUCATION").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                            ForEach(model.resume.education) { edu in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(edu.institution).bold()
                                    Text("\(edu.degree) • \(edu.startDate) – \(edu.endDate)").font(.footnote).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding()
        }
        .background(Color.gray.opacity(0.04))
        .accessibilityElement(children: .combine)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .accessibilityAddTraits(.isHeader)
    }

    private func exportResume() {
        let fileName = SafeFileName.sanitized("\(model.resume.basics.fullName) - CV.pdf")
        if let url = PDFGenerator.generatePDF(from: model.resume, fileName: fileName) {
            print("Saved PDF at: \(url.path)")
        }
    }
}

private enum SafeFileName {
    static func sanitized(_ raw: String) -> String {
        let invalid = CharacterSet(charactersIn: "\\/:*?\"<>|\n\r")
        let replaced = raw.unicodeScalars.map { invalid.contains($0) ? "-" : String($0) }.joined()
        return replaced.replacingOccurrences(of: " ", with: " ")
    }
}

#Preview {
    CanvasView(model: .init())
}
