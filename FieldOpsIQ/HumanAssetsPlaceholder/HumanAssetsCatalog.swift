import Foundation

struct HumanAssetPlaceholder: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    var systemImage: String
}

enum HumanAssetsCatalog {
    static let dashboardHero = HumanAssetPlaceholder(
        title: "Field Engineer Hero",
        description: "Premium technician imagery placeholder for dark industrial dashboard surfaces.",
        systemImage: "person.crop.rectangle.badge.gearshape"
    )

    static let equipment = [
        HumanAssetPlaceholder(title: "ONT Close-up", description: "Realistic ONT equipment photo slot.", systemImage: "dot.radiowaves.left.and.right"),
        HumanAssetPlaceholder(title: "Fiber Cabinet", description: "Street cabinet and patching image slot.", systemImage: "shippingbox.fill"),
        HumanAssetPlaceholder(title: "Patch Panel", description: "Rack and fiber patching image slot.", systemImage: "rectangle.grid.3x2.fill"),
        HumanAssetPlaceholder(title: "Wireless Mount", description: "Wireless infrastructure installation image slot.", systemImage: "antenna.radiowaves.left.and.right")
    ]
}
