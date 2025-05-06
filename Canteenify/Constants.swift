import SwiftUI

struct Constants {
    // MARK: - Gray colors
    static let gray50: Color = Color(hex: "f9fafb")
    static let gray100: Color = Color(hex: "f3f4f6")
    static let gray200: Color = Color(hex: "e5e7eb")
    static let gray300: Color = Color(hex: "d1d5db")
    static let gray400: Color = Color(hex: "9ca3af")
    static let gray500: Color = Color(hex: "6b7280")
    static let gray600: Color = Color(hex: "4b5563")
    static let gray700: Color = Color(hex: "374151")
    static let gray800: Color = Color(hex: "1f2937")
    static let gray900: Color = Color(hex: "111827")
    static let gray950: Color = Color(hex: "030712")
    
    // MARK: - Green colors
    static let green50: Color = Color(hex: "f0fdf4")
    static let green100: Color = Color(hex: "dcfce7")
    static let green200: Color = Color(hex: "bbf7d0")
    static let green300: Color = Color(hex: "86efac")
    static let green400: Color = Color(hex: "4ade80")
    static let green500: Color = Color(hex: "22c55e")
    static let green600: Color = Color(hex: "16a34a")
    static let green700: Color = Color(hex: "15803d")
    static let green800: Color = Color(hex: "166534")
    static let green900: Color = Color(hex: "14532d")
    static let green950: Color = Color(hex: "052e16")
    
    // MARK: - Amber colors
    static let amber50: Color = Color(hex: "fffbeb")
    static let amber100: Color = Color(hex: "fef3c7")
    static let amber200: Color = Color(hex: "fde68a")
    static let amber300: Color = Color(hex: "fcd34d")
    static let amber400: Color = Color(hex: "fbbf24")
    static let amber500: Color = Color(hex: "f59e0b")
    static let amber600: Color = Color(hex: "d97706")
    static let amber700: Color = Color(hex: "b45309")
    static let amber800: Color = Color(hex: "92400e")
    static let amber900: Color = Color(hex: "78350f")
    static let amber950: Color = Color(hex: "451a03")
    
    // MARK: - Red colors
    static let red50: Color = Color(hex: "fef2f2")
    static let red100: Color = Color(hex: "fee2e2")
    static let red200: Color = Color(hex: "fecaca")
    static let red300: Color = Color(hex: "fca5a5")
    static let red400: Color = Color(hex: "f87171")
    static let red500: Color = Color(hex: "ef4444")
    static let red600: Color = Color(hex: "dc2626")
    static let red700: Color = Color(hex: "b91c1c")
    static let red800: Color = Color(hex: "991b1b")
    static let red900: Color = Color(hex: "7f1d1d")
    static let red950: Color = Color(hex: "450a0a")
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
