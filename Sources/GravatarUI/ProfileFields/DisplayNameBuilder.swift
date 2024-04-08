import UIKit

public struct DisplayNameBuilder {
    let label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    @discardableResult
    public func content(_ model: DisplayNameModel) -> DisplayNameBuilder {
        label.text = model.displayName ?? model.fullName ?? model.userName
        label.font = .DS.title1
        label.numberOfLines = 0
        return self
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> DisplayNameBuilder {
        label.textColor = paletteType.palette.foreground.primary
        return self
    }
}