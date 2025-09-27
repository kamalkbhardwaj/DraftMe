//
//  Untitled.swift
//  DraftMe
//
//  Created by Kamal Kishor on 15/09/25.
//

import SwiftUI
import UIKit
import PDFKit
import CoreText

struct PDFGenerator {
    static private let a4Size = CGSize(width: 595, height: 842) // A4 at 72 DPI
    static private let pageMargins = UIEdgeInsets(top: 48, left: 48, bottom: 48, right: 48)

    // Legacy rasterizing API (kept for compatibility; not ATS-optimal).
    static func generatePDF<V: View>(from views: [V], fileURL: URL) {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: a4Size))
        let data = renderer.pdfData { context in
            for view in views {
                let hostingController = UIHostingController(rootView: view)
                hostingController.view.frame = CGRect(origin: .zero, size: a4Size)
                context.beginPage()
                hostingController.view.layer.render(in: context.cgContext)
            }
        }
        try? data.write(to: fileURL)
    }

    // ATS-friendly: text stays selectable and searchable.
    static func generatePDF(from resume: Resume, fileName: String) -> URL? {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let outURL = (docURL ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent(fileName)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: a4Size))
        let data = renderer.pdfData { ctx in
            let contentRect = CGRect(
                x: pageMargins.left,
                y: pageMargins.top,
                width: a4Size.width - pageMargins.left - pageMargins.right,
                height: a4Size.height - pageMargins.top - pageMargins.bottom
            )

            let attributed = makeAttributedResume(resume)
            var framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)
            var currentRange = CFRange(location: 0, length: 0)
            var done = false

            while !done {
                ctx.beginPage()
                let path = CGMutablePath()
                path.addRect(contentRect)
                let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)
                if let context = UIGraphicsGetCurrentContext() {
                    context.textMatrix = .identity
                    context.translateBy(x: 0, y: a4Size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                }
                CTFrameDraw(frame, UIGraphicsGetCurrentContext()!)

                let visibleRange = CTFrameGetVisibleStringRange(frame)
                currentRange = CFRange(location: visibleRange.location + visibleRange.length, length: 0)
                if currentRange.location >= attributed.length {
                    done = true
                }
            }
        }

        do {
            try data.write(to: outURL)
            return outURL
        } catch {
            print("PDF write failed: \(error)")
            return nil
        }
    }

    private static func makeAttributedResume(_ resume: Resume) -> NSAttributedString {
        let bodyFont = UIFont.systemFont(ofSize: 11)
        let headerFont = UIFont.boldSystemFont(ofSize: 20)
        let subHeaderFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let bold = UIFont.boldSystemFont(ofSize: 11)

        let para = NSMutableParagraphStyle()
        para.lineSpacing = 2
        para.paragraphSpacing = 6

        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .paragraphStyle: para
        ]

        let builder = NSMutableAttributedString()

        // Header
        builder.append(NSAttributedString(string: resume.basics.fullName + "\n", attributes: [.font: headerFont]))
        builder.append(NSAttributedString(string: resume.basics.title + "\n\n", attributes: [.font: subHeaderFont]))
        let contacts = [resume.basics.email, resume.basics.phone, resume.basics.location, resume.basics.website, resume.basics.linkedin, resume.basics.github]
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
        builder.append(NSAttributedString(string: contacts + "\n\n", attributes: bodyAttrs))

        // Summary
        builder.append(NSAttributedString(string: "PROFESSIONAL SUMMARY\n", attributes: [.font: subHeaderFont]))
        builder.append(NSAttributedString(string: resume.summary + "\n\n", attributes: bodyAttrs))

        // Experience
        builder.append(NSAttributedString(string: "EXPERIENCE\n", attributes: [.font: subHeaderFont]))
        for exp in resume.experience {
            builder.append(NSAttributedString(string: "\(exp.role) – \(exp.company)\n", attributes: [.font: bold]))
            builder.append(NSAttributedString(string: "\(exp.location) • \(exp.startDate) – \(exp.endDate)\n", attributes: bodyAttrs))
            for bullet in exp.bullets where !bullet.isEmpty {
                builder.append(NSAttributedString(string: "• \(bullet)\n", attributes: bodyAttrs))
            }
            builder.append(NSAttributedString(string: "\n", attributes: bodyAttrs))
        }

        // Skills
        if !resume.skills.isEmpty {
            builder.append(NSAttributedString(string: "SKILLS\n", attributes: [.font: subHeaderFont]))
            builder.append(NSAttributedString(string: resume.skills.joined(separator: ", ") + "\n\n", attributes: bodyAttrs))
        }

        // Certifications
        if !resume.certifications.isEmpty {
            builder.append(NSAttributedString(string: "CERTIFICATIONS\n", attributes: [.font: subHeaderFont]))
            for cert in resume.certifications {
                builder.append(NSAttributedString(string: "• \(cert)\n", attributes: bodyAttrs))
            }
            builder.append(NSAttributedString(string: "\n", attributes: bodyAttrs))
        }

        // Education
        if !resume.education.isEmpty {
            builder.append(NSAttributedString(string: "EDUCATION\n", attributes: [.font: subHeaderFont]))
            for edu in resume.education {
                builder.append(NSAttributedString(string: "\(edu.institution)\n", attributes: [.font: bold]))
                builder.append(NSAttributedString(string: "\(edu.degree) • \(edu.startDate) – \(edu.endDate)\n\n", attributes: bodyAttrs))
            }
        }

        return builder
    }
}
