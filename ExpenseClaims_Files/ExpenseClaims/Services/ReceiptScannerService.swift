import Foundation
import Vision
import UIKit

/// Extracted fields pulled from a receipt image.
struct ExtractedBillInfo {
    var vendorName: String?
    var amount: Double?
    var date: Date?
    var rawText: String
}

/// Performs on-device OCR + light heuristics to pull vendor name, total amount,
/// and date out of a photographed/uploaded receipt. This plays the role of the
/// "Extracting bill information using GenAI solution" step in the reference flow,
/// implemented with Apple's Vision framework so it works fully offline.
enum ReceiptScannerService {

    static func extract(from image: UIImage) async throws -> ExtractedBillInfo {
        guard let cgImage = image.cgImage else {
            throw ScannerError.invalidImage
        }

        let lines = try await recognizeText(in: cgImage)
        let rawText = lines.joined(separator: "\n")

        return ExtractedBillInfo(
            vendorName: guessVendorName(from: lines),
            amount: guessTotalAmount(from: lines),
            date: guessDate(from: lines),
            rawText: rawText
        )
    }

    enum ScannerError: LocalizedError {
        case invalidImage
        var errorDescription: String? {
            switch self {
            case .invalidImage: return "The selected image could not be read."
            }
        }
    }

    // MARK: - OCR

    private static func recognizeText(in cgImage: CGImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Heuristics

    /// Vendor name is usually one of the first non-empty, mostly-alphabetic lines.
    private static func guessVendorName(from lines: [String]) -> String? {
        for line in lines.prefix(6) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let letters = trimmed.filter { $0.isLetter }
            if trimmed.count >= 3, letters.count > trimmed.count / 2, !looksLikeAddressOrPhone(trimmed) {
                return trimmed
            }
        }
        return lines.first
    }

    private static func looksLikeAddressOrPhone(_ text: String) -> Bool {
        let digits = text.filter { $0.isNumber }.count
        return digits > text.count / 3
    }

    /// Finds the largest currency-like amount on lines mentioning "total".
    /// Falls back to the largest currency-like amount anywhere on the receipt.
    private static func guessTotalAmount(from lines: [String]) -> Double? {
        let amountRegex = try? NSRegularExpression(pattern: #"[\$₹€£]?\s?(\d{1,3}(?:[,.]\d{3})*(?:\.\d{2})?)"#)

        func amounts(in line: String) -> [Double] {
            guard let amountRegex else { return [] }
            let range = NSRange(line.startIndex..., in: line)
            let matches = amountRegex.matches(in: line, range: range)
            return matches.compactMap { match -> Double? in
                guard let r = Range(match.range(at: 1), in: line) else { return nil }
                let cleaned = line[r].replacingOccurrences(of: ",", with: "")
                return Double(cleaned)
            }
        }

        let totalKeywords = ["total due", "total amount", "grand total", "total"]
        for line in lines {
            let lower = line.lowercased()
            if totalKeywords.contains(where: { lower.contains($0) }) {
                if let value = amounts(in: line).max() {
                    return value
                }
            }
        }

        // Fallback: largest amount found anywhere on the receipt.
        let all = lines.flatMap { amounts(in: $0) }
        return all.max()
    }

    private static func guessDate(from lines: [String]) -> Date? {
        let formatters: [DateFormatter] = ["yyyy-MM-dd", "MM/dd/yyyy", "dd/MM/yyyy", "MMM dd, yyyy", "MMMM dd, yyyy"]
            .map { fmt in
                let f = DateFormatter()
                f.dateFormat = fmt
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }

        for line in lines {
            for formatter in formatters {
                if let date = formatter.date(from: line.trimmingCharacters(in: .whitespaces)) {
                    return date
                }
            }
            // Try to find a date-like substring within a longer line (e.g. "Invoice Date: June 22, 2026")
            if let range = line.range(of: #"[A-Za-z]{3,9}\s\d{1,2},?\s\d{4}"#, options: .regularExpression) {
                let candidate = String(line[range])
                let f = DateFormatter()
                f.dateFormat = "MMMM d, yyyy"
                f.locale = Locale(identifier: "en_US_POSIX")
                if let date = f.date(from: candidate) { return date }
                f.dateFormat = "MMM d, yyyy"
                if let date = f.date(from: candidate) { return date }
            }
        }
        return nil
    }
}
