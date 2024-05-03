import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileViewSnapshots: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = ProfileView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "profileView")
        }
    }

    func testProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = ProfileSummaryView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "profileSummaryView")
        }
    }

    func testLargeProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = LargeProfileView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "largeProfileView")
        }
    }

    func testLargeProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = LargeProfileSummaryView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "largeProfileSummaryView")
        }
    }

    private func wrap(_ view: BaseProfileView) -> UIView {
        view.avatarImageView.backgroundColor = .systemBlue
        view.avatarImageView.image = ImageHelper.exampleAvatarImage
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return view.wrapInSuperView(with: Constants.width)
    }
}

extension TestProfileCardModel {
    fileprivate static let exampleModel = TestProfileCardModel(
        accountsList: [
            TestAccountModel(display: "Gravatar", shortname: "gravatar"),
            TestAccountModel(display: "WordPress", shortname: "wordpress"),
            TestAccountModel(display: "Tumblr", shortname: "tumblr"),
            TestAccountModel(display: "GitHub", shortname: "github"),
        ],
        aboutMe: "Engineer at heart, problem-solver by nature. Passionate about innovation and pushing boundaries. Let's build something incredible together.",
        displayName: "John Appleseed",
        fullName: "John Appleseed",
        userName: "username",
        jobTitle: "Engineer",
        pronouns: "he/him",
        currentLocation: "Atlanta GA",
        avatarIdentifier: .email("email@domain.com"),
        profileURL: URL(string: "https://gravatar.com/profile")
    )
}