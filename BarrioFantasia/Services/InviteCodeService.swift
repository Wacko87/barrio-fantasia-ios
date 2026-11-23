import Foundation
import CoreImage.CIFilterBuiltins
import UIKit
import SwiftUI

public final class InviteCodeService: Sendable {
    public static let shared = InviteCodeService()

    private let context = CIContext()

    private init() {}

    public var currentLeagueCode: String {
        let saved = UserDefaults.standard.string(forKey: "current_league_invite_code")
        if let code = saved, !code.isEmpty {
            return code
        }
        let newCode = "BF-" + String((0..<4).map { _ in "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".randomElement()! })
        UserDefaults.standard.set(newCode, forKey: "current_league_invite_code")
        return newCode
    }

    public func generateQRCodeImage(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        // Scale up to crisp 512x512
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)

        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    public func validateAndJoin(code: String) -> Bool {
        let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard cleaned.count >= 4 else { return false }
        UserDefaults.standard.set(cleaned, forKey: "current_league_invite_code")
        UserDefaults.standard.set(true, forKey: "has_joined_league")
        return true
    }
}
