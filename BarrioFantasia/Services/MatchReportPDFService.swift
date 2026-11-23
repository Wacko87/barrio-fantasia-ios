import UIKit
import PDFKit
import SwiftUI

public struct MatchPDFDocument: Transferable {
    public let pdfData: Data
    public let title: String

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { item in
            item.pdfData
        }
        .suggestedFileName { item in
            "Acta_\(item.title.replacingOccurrences(of: " ", with: "_")).pdf"
        }
    }
}

public struct PlayerReportSnapshot: Sendable {
    public let number: Int
    public let displayName: String
    public let position: String
    public let avgRating: Double

    public init(number: Int, displayName: String, position: String, avgRating: Double) {
        self.number = number
        self.displayName = displayName
        self.position = position
        self.avgRating = avgRating
    }
}

public struct MatchReportSnapshot: Sendable {
    public let title: String
    public let date: Date
    public let location: String
    public let format: String
    public let scoreTeamA: Int
    public let scoreTeamB: Int
    public let teamA: [PlayerReportSnapshot]
    public let teamB: [PlayerReportSnapshot]

    public init(
        title: String,
        date: Date,
        location: String,
        format: String,
        scoreTeamA: Int,
        scoreTeamB: Int,
        teamA: [PlayerReportSnapshot],
        teamB: [PlayerReportSnapshot]
    ) {
        self.title = title
        self.date = date
        self.location = location
        self.format = format
        self.scoreTeamA = scoreTeamA
        self.scoreTeamB = scoreTeamB
        self.teamA = teamA
        self.teamB = teamB
    }
}

/// Swift 6 actor that isolates heavy PDF rendering to a background worker.
public actor MatchReportPDFService {
    public static let shared = MatchReportPDFService()

    private init() {}

    public func generateReport(from snapshot: MatchReportSnapshot) -> Data {
        let pageWidth: CGFloat = 595.2 // A4 standard
        let pageHeight: CGFloat = 841.8
        let bounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        return renderer.pdfData { ctx in
            ctx.beginPage()

            // 1. Header Background Banner
            let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: 110)
            let headerColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            headerColor.setFill()
            ctx.cgContext.fill(headerRect)

            // Red Accent Strip
            let accentRect = CGRect(x: 0, y: 106, width: pageWidth, height: 4)
            let redColor = UIColor(red: 0.89, green: 0.11, blue: 0.15, alpha: 1.0)
            redColor.setFill()
            ctx.cgContext.fill(accentRect)

            // Header Titles
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .black),
                .foregroundColor: UIColor.white
            ]
            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor(white: 0.8, alpha: 1.0)
            ]

            "BARRIO DE FANTASÍA".draw(at: CGPoint(x: 36, y: 32), withAttributes: titleAttrs)
            "ACTA OFICIAL DE PARTIDO Y HOJA DE VALORACIONES".draw(at: CGPoint(x: 36, y: 64), withAttributes: subtitleAttrs)

            // 2. Match Metadata Box
            var currentY: CGFloat = 130
            let metaTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let metaBodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]

            snapshot.title.draw(at: CGPoint(x: 36, y: currentY), withAttributes: metaTitleAttrs)
            currentY += 24

            let dateString = snapshot.date.formatted(date: .long, time: .shortened)
            "Fecha: \(dateString)  |  Lugar: \(snapshot.location)  |  Formato: \(snapshot.format)".draw(at: CGPoint(x: 36, y: currentY), withAttributes: metaBodyAttrs)
            currentY += 30

            // 3. Scoreboard Box
            let scoreBox = CGRect(x: 36, y: currentY, width: pageWidth - 72, height: 70)
            let scoreBg = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
            scoreBg.setFill()
            ctx.cgContext.fill(scoreBox)

            let scoreAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .black),
                .foregroundColor: redColor
            ]
            let teamLabelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.black
            ]

            "EQUIPO A".draw(at: CGPoint(x: 60, y: currentY + 24), withAttributes: teamLabelAttrs)
            "\(snapshot.scoreTeamA)  —  \(snapshot.scoreTeamB)".draw(at: CGPoint(x: pageWidth / 2 - 40, y: currentY + 16), withAttributes: scoreAttrs)
            "EQUIPO B".draw(at: CGPoint(x: pageWidth - 140, y: currentY + 24), withAttributes: teamLabelAttrs)

            currentY += 95

            // 4. Lineups and Ratings Tables
            let colWidth = (pageWidth - 92) / 2

            // Equipo A Column
            drawTeamColumn(title: "EQUIPO A", players: snapshot.teamA, startX: 36, startY: currentY, width: colWidth)

            // Equipo B Column
            drawTeamColumn(title: "EQUIPO B", players: snapshot.teamB, startX: 36 + colWidth + 20, startY: currentY, width: colWidth)

            // 5. Official Verification Stamp (Footer)
            let footerY = pageHeight - 50
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            "Documento generado electrónicamente por Barrio de Fantasía iOS. Válido para estadísticas oficiales y cómputo de liga Fantasy.".draw(at: CGPoint(x: 36, y: footerY), withAttributes: footerAttrs)
        }
    }

    private func drawTeamColumn(title: String, players: [PlayerReportSnapshot], startX: CGFloat, startY: CGFloat, width: CGFloat) {
        let colTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor(red: 0.89, green: 0.11, blue: 0.15, alpha: 1.0)
        ]
        let rowAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        let rowSubAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .bold),
            .foregroundColor: UIColor.darkGray
        ]

        title.draw(at: CGPoint(x: startX, y: startY), withAttributes: colTitleAttrs)
        var y = startY + 20

        for player in players {
            let rowText = "#\(player.number)  \(player.displayName) (\(player.position))"
            rowText.draw(at: CGPoint(x: startX, y: y), withAttributes: rowAttrs)

            let ratingText = "Nota: \(String(format: "%.1f", player.avgRating))"
            ratingText.draw(at: CGPoint(x: startX + width - 60, y: y), withAttributes: rowSubAttrs)

            y += 18
        }
    }
}
