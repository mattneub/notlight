import Foundation

/// Protocol that describes Bundle so we can mock it for testing.
protocol BundleType {
    func url(
        forResource name: String?,
        withExtension ext: String?
    ) -> URL?
    func url(
        forResource name: String?,
        withExtension ext: String?,
        subdirectory: String?,
    ) -> URL?
}

extension Bundle: BundleType {}
