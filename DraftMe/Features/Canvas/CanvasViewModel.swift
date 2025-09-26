//
//  CanvasViewModel.swift
//  DraftMe
//
//  Created by Kamal Kishor on 14/09/25.
//

import Foundation

@Observable
final class CanvasViewModel {
    var state: CanvasState = .editing
    var resume: Resume

    init(resume: Resume = .placeholder) {
        self.resume = resume
    }

    func addExperience() {
        resume.experience.append(
            .init(role: "Job Title", company: "Company", location: "City, Country", startDate: "Start", endDate: "End", bullets: ["Achievement or responsibility."])
        )
    }

    func removeExperience(at indexSet: IndexSet) {
        resume.experience.remove(atOffsets: indexSet)
    }

    func addSkill(_ skill: String) {
        guard !skill.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        resume.skills.append(skill)
    }

    func removeSkill(at indexSet: IndexSet) {
        resume.skills.remove(atOffsets: indexSet)
    }

    func addCertification(_ cert: String) {
        guard !cert.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        resume.certifications.append(cert)
    }

    func removeCertification(at indexSet: IndexSet) {
        resume.certifications.remove(atOffsets: indexSet)
    }
}
