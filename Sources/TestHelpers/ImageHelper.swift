import UIKit

package class ImageHelper {
    private init() {}

    static let testResourcesDir = "Gravatar_Gravatar-Tests.bundle/ResourceFiles/"

    package static var testImage: UIImage {
        image(named: "test", type: "png")!
    }

    package static var testImageData: Data {
        dataFromImage(named: "test", type: "png")!
    }

    package static var placeholderImage: UIImage {
        image(named: "placeholder", type: "png")!
    }

    package static var exampleAvatarImage: UIImage {
        image(named: "example_avatar", type: "png")!
    }

    static func dataFromImage(named: String, type: String) -> Data? {
        guard let url = Bundle.module.url(forResource: named, withExtension: type) else {
            return nil
        }
        var data: Data? = nil
        do {
            data = try Data(contentsOf: url)
        } catch {}
        return data
    }

    static func image(named: String, type: String) -> UIImage? {
        guard let path = Bundle.module.path(forResource: named, ofType: type) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}
