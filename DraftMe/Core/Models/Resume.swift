//
//  Resume.swift
//  DraftMe
//
//  Moved to Core/Models for reuse across features.
//

import Foundation

struct Resume: Sendable, Codable, Equatable {
    var basics: Basics
    var summary: String
    var experience: [Experience]
    var education: [Education]
    var skills: [String]
    var certifications: [String]
    var projects: [Project]
}

struct Basics: Sendable, Codable, Equatable {
    var fullName: String
    var title: String
    var email: String
    var phone: String
    var location: String
    var website: String
    var linkedin: String
    var github: String
}

struct Experience: Sendable, Codable, Equatable, Identifiable {
    var id: UUID = .init()
    var role: String
    var company: String
    var location: String
    var startDate: String
    var endDate: String
    var bullets: [String]
}

struct Education: Sendable, Codable, Equatable, Identifiable {
    var id: UUID = .init()
    var institution: String
    var degree: String
    var startDate: String
    var endDate: String
}

struct Project: Sendable, Codable, Equatable, Identifiable {
    var id: UUID = .init()
    var name: String
    var description: String
    var highlights: [String]
}

extension Resume {
    static var placeholder: Resume {
        .init(
            basics: .init(
                fullName: "Alex Johnson",
                title: "Senior iOS Engineer",
                email: "alex.johnson@example.com",
                phone: "+44 7700 900123",
                location: "London, UK",
                website: "alexjohnson.dev",
                linkedin: "linkedin.com/in/alexjohnson",
                github: "github.com/alexjohnson"
            ),
            summary: "Senior iOS Engineer with 8+ years building accessible, high-performance apps. Led teams, shipped at scale, and improved reliability and developer velocity.",
            experience: [
                .init(
                    role: "Lead iOS Engineer",
                    company: "Acme Corp",
                    location: "London, UK",
                    startDate: "Jan 2021",
                    endDate: "Present",
                    bullets: [
                        "Led a team of 5 to deliver a modular SwiftUI architecture.",
                        "Improved app start time by 35% using lazy loading and caching.",
                        "Drove accessibility compliance (WCAG 2.1 AA)."
                    ]
                ),
                .init(
                    role: "iOS Engineer",
                    company: "Globex",
                    location: "Manchester, UK",
                    startDate: "Jul 2017",
                    endDate: "Dec 2020",
                    bullets: [
                        "Built offline-first sync using background tasks and Core Data.",
                        "Implemented CI/CD with unit/UI tests, cutting release time by 40%."
                    ]
                )
            ],
            education: [
                .init(
                    institution: "University of Leeds",
                    degree: "BSc Computer Science",
                    startDate: "2013",
                    endDate: "2016"
                )
            ],
            skills: [
                "Swift", "SwiftUI", "UIKit", "Combine", "Concurrency",
                "Core Data", "REST", "GraphQL", "CI/CD", "Testing"
            ],
            certifications: [
                "AWS Certified Cloud Practitioner", "Scrum Master (PSM I)"
            ],
            projects: [
                .init(
                    name: "OpenWeather Client",
                    description: "A lightweight, testable Swift package for weather APIs.",
                    highlights: ["95% test coverage", "Async/await based API"]
                )
            ]
        )
    }
}

