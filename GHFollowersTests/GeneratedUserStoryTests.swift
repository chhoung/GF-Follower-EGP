
// GeneratedUserStoryTests.swift, AUTO-GENERATED, Copyright © 2025 Kimchhorng Pheng

import Testing
import UIKit
@testable import GHFollowers

@MainActor
struct GeneratedUserStoryTests {

    // US-001: Search for GitHub User
    @Test("US-001: SearchVC basic wiring")
    func testSearchVCBasicWiring() throws {
        let vc = SearchVC()
        _ = vc.view // trigger load
        #expect(vc.view.backgroundColor == .systemBackground)
        #expect(vc.callToActionButton.titleLabel?.text == "Get Followers")
        #expect(vc.usernameTextField.placeholder == "Enter a username")
    }

    // US-002: Handle Empty Username Search
    @Test("US-002: Empty username presents custom alert VC")
    func testEmptyUsernamePresentsAlert() throws {
        let root = UINavigationController(rootViewController: SearchVC())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = root
        window.makeKeyAndVisible()

        guard let search = root.topViewController as? SearchVC else {
            Issue.record("Root top VC is not SearchVC")
            return
        }

        _ = search.view
        search.usernameTextField.text = "" // empty
        search.pushFollowerListVC()

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        #expect(search.presentedViewController is GFAlertVC)

        if let alert = search.presentedViewController as? GFAlertVC {
            _ = alert.view
            #expect(alert.titleLabel.text == "Empty Username")
            #expect(alert.messageLabel.text == "Please enter a username. We need to know who to look for 😀.")
            #expect(alert.actionButton.titleLabel?.text == "Ok")
        }
    }

    // US-003: Dismiss Keyboard
    @Test("US-003: Dismiss keyboard tap gesture exists")
    func testDismissKeyboardGestureExists() throws {
        let vc = SearchVC()
        _ = vc.view
        let gestures = vc.view.gestureRecognizers ?? []
        let hasTap = gestures.contains { $0 is UITapGestureRecognizer }
        #expect(hasTap)
    }

    // US-004: Clear Text Field on Return
    @Test("US-004: Text field cleared in viewWillAppear")
    func testTextFieldClearedOnAppear() throws {
        let nav = UINavigationController(rootViewController: UIViewController())
        let search = SearchVC()
        nav.pushViewController(search, animated: false)

        _ = search.view
        search.usernameTextField.text = "octocat"
        search.viewWillAppear(false)
        #expect((search.usernameTextField.text ?? "").isEmpty)
    }

    // US-005: View Followers in Grid
    @Test("US-005: Follower list grid and dataSource configured")
    func testFollowerListGridSetup() throws {
        let vc = FollowerListVC(username: "octocat")
        _ = vc.view // triggers viewDidLoad
        #expect(vc.collectionView != nil)
        #expect(vc.dataSource != nil)

        #expect(vc.collectionView.collectionViewLayout is UICollectionViewFlowLayout)
        if let flow = vc.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = vc.view.bounds.width
            let padding: CGFloat = 12
            let spacing: CGFloat = 10
            let available = width - (padding * 2) - (spacing * 2)
            let expectedItemWidth = available / 3
            #expect(flow.itemSize.width == expectedItemWidth)
        }
    }

    // US-006: Search Through Followers
    @Test("US-006: Search filters followers in real-time")
    func testSearchFiltersFollowers() throws {
        let vc = FollowerListVC(username: "octocat")
        _ = vc.view

        vc.followers = [
            Follower(login: "Alice", avatarUrl: ""),
            Follower(login: "bob", avatarUrl: ""),
            Follower(login: "Charlie", avatarUrl: "")
        ]
        vc.configureCollectionView()
        vc.configureDataSource()

        let searchController = UISearchController()
        searchController.searchBar.text = "Bo"
        vc.updateSearchResults(for: searchController)

        #expect(vc.isSearching)
        #expect(vc.filteredFollowers.count == 1)
        #expect(vc.filteredFollowers.first?.login == "bob")
    }

    // US-007: Empty State for No Followers
    @Test("US-007: Empty state shown when no followers")
    func testEmptyStateForNoFollowers() throws {
        let vc = FollowerListVC(username: "someone")
        _ = vc.view

        vc.isLoadingMoreFollowers = false
        vc.followers = []
        vc.updateUI(with: [])
        vc.updateContentUnavailableConfiguration(using: vc.contentUnavailableConfigurationState)

        guard let config = vc.contentUnavailableConfiguration as? UIContentUnavailableConfiguration else {
            #expect(Bool(false), "Expected UIContentUnavailableConfiguration, but got \(String(describing: vc.contentUnavailableConfiguration))")
            return
        }

        #expect(config.text == "No Followers")
        #expect(config.secondaryText == "This user has no followers. Go follow them!")
    }

    // US-008: Selecting Follower Opens User Info
    @Test("US-008: Selecting follower presents UserInfoVC")
    func testSelectingFollowerPresentsUserInfoVC() throws {
        let vc = FollowerListVC(username: "octocat")
        let window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        _ = vc.view

        vc.followers = [Follower(login: "octodog", avatarUrl: "")]
        vc.configureCollectionView()
        vc.configureDataSource()

        let indexPath = IndexPath(item: 0, section: 0)
        vc.collectionView(vc.collectionView, didSelectItemAt: indexPath)

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        #expect(vc.presentedViewController is UINavigationController)
        if let presentedNav = vc.presentedViewController as? UINavigationController {
            #expect(presentedNav.topViewController is UserInfoVC)
            if let userInfo = presentedNav.topViewController as? UserInfoVC {
                #expect(userInfo.username == "octodog")
            }
        }
    }

    // US-009: Empty Favorites State
    @Test("US-009: Empty Favorites state displayed")
    func testEmptyFavoritesState() throws {
        let vc = FavoritesListVC()
        vc.loadViewIfNeeded()

        vc.favorites = []
        vc.updateUI(with: [])
        vc.updateContentUnavailableConfiguration(using: vc.contentUnavailableConfigurationState)

        guard let config = vc.contentUnavailableConfiguration as? UIContentUnavailableConfiguration else {
            #expect(Bool(false), "Expected UIContentUnavailableConfiguration, but got \(String(describing: vc.contentUnavailableConfiguration))")
            return
        }

        #expect(config.text == "No Favorites")
        #expect(config.secondaryText == "Add a favorite on the follower list screen")
    }
}
