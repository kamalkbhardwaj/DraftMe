//
//  PDFGenerator.swift
//  DraftMe
//
//  Created by Kamal Kishor on 15/09/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import PDFKit
import CoreText

struct PDFGenerator {
    // MARK: - Page settings
    static private let a4Size = CGSize(width: 595, height: 842) // A4 at 72 DPI
    private struct Insets { let top: CGFloat; let left: CGFloat; let bottom: CGFloat; let right: CGFloat }
    static private let pageMargins = Insets(top: 48, left: 48, bottom: 48, right: 48)

    // Legacy rasterizing API (kept for compatibility; not ATS-optimal, iOS only).
    #if canImport(UIKit)
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
    #endif

    // MARK: - ATS-friendly export (text stays selectable/searchable)
    static func generatePDF(from resume: Resume, fileName: String) -> URL? {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let outURL = (docURL ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent(fileName)

        // Create a CoreGraphics PDF context that works on iOS and macOS.
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else { return nil }
        var mediaBox = CGRect(origin: .zero, size: a4Size)
        guard let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return nil }

        let contentRect = CGRect(
            x: pageMargins.left,
            y: pageMargins.top,
            width: a4Size.width - pageMargins.left - pageMargins.right,
            height: a4Size.height - pageMargins.top - pageMargins.bottom
        )

        let attributedText = makeAttributedResume(resume)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        var currentRange = CFRange(location: 0, length: 0)

        while currentRange.location < attributedText.length {
            ctx.beginPDFPage(nil)

            let path = CGMutablePath()
            path.addRect(contentRect)
            let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)

            ctx.saveGState()
            ctx.textMatrix = .identity
            ctx.translateBy(x: 0, y: a4Size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            CTFrameDraw(frame, ctx)
            ctx.restoreGState()

            let visibleRange = CTFrameGetVisibleStringRange(frame)
            currentRange = CFRange(location: visibleRange.location + visibleRange.length, length: 0)
            ctx.endPDFPage()
        }

        ctx.closePDF()

        do {
            try data.write(to: outURL)
            return outURL
        } catch {
            print("PDF write failed: \(error)")
            return nil
        }
    }

    private static func makeAttributedResume(_ resume: Resume) -> NSAttributedString {
        // Cross-platform font helpers
        enum FontWeight { case regular, bold, semibold }
        func platformFont(_ size: CGFloat, _ weight: FontWeight) -> Any {
            #if canImport(UIKit)
            switch weight {
            case .regular: return UIFont.systemFont(ofSize: size)
            case .bold: return UIFont.boldSystemFont(ofSize: size)
            case .semibold: return UIFont.systemFont(ofSize: size, weight: .semibold)
            }
            #elseif canImport(AppKit)
            switch weight {
            case .regular: return NSFont.systemFont(ofSize: size)
            case .bold: return NSFont.boldSystemFont(ofSize: size)
            case .semibold: return NSFont.systemFont(ofSize: size, weight: .semibold)
            }
            #else
            // Fallback to CoreText fonts if neither UIKit nor AppKit is available
            let name: CFString
            switch weight {
            case .regular: name = "Helvetica" as CFString
            case .bold: name = "Helvetica-Bold" as CFString
            case .semibold: name = "Helvetica-Bold" as CFString
            }
            return CTFontCreateWithName(name, size, nil)
            #endif
        }

        let bodyFont = platformFont(11, .regular)
        let headerFont = platformFont(20, .bold)
        let subHeaderFont = platformFont(12, .semibold)
        let boldFont = platformFont(11, .bold)

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
            builder.append(NSAttributedString(string: "\(exp.role) – \(exp.company)\n", attributes: [.font: boldFont]))
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
                builder.append(NSAttributedString(string: "\(edu.institution)\n", attributes: [.font: boldFont]))
                builder.append(NSAttributedString(string: "\(edu.degree) • \(edu.startDate) – \(edu.endDate)\n\n", attributes: bodyAttrs))
            }
        }

        return builder
    }
}
