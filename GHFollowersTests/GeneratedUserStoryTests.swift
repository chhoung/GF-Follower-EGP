//
//  GeneratedUserStoryTests.swift
//  GHFollowersTests
//
//  AUTO-GENERATED FILE. DO NOT EDIT MANUALLY.
//

import Testing
import UIKit
@testable import GHFollowers

@MainActor
struct GeneratedUserStoryTests {


    // US-001: Search for GitHub User
    // Screen: SearchVC
    // Priority: high
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - User can enter a username in the text field
        - User can tap 'Get Followers' button to search
        - User can press return key to submit search
        - App navigates to follower list screen on successful search
    */
    @Test("US-001: Search for GitHub User")
    func testSearchForGithubUser() throws {
        let vc = SearchVC()
        _ = vc.view // trigger load
        #expect(vc.view.backgroundColor == .systemBackground)
        #expect(vc.callToActionButton.titleLabel?.text == "Get Followers")
        #expect(vc.usernameTextField.placeholder == "Enter a username")
    }


    // US-002: Handle Empty Username Search
    // Screen: SearchVC
    // Priority: high
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Alert appears when 'Get Followers' is tapped with empty text field
        - Alert shows title 'Empty Username'
        - Alert shows message 'Please enter a username. We need to know who to look for 😀.'
        - Alert has 'Ok' button to dismiss
    */
    @Test("US-002: Handle Empty Username Search")
    func testHandleEmptyUsernameSearch() throws {
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

        // The project uses a custom GFAlertVC presented modally
        // Give runloop a brief chance for presentation
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        #expect(search.presentedViewController is GFAlertVC)

        if let alert = search.presentedViewController as? GFAlertVC {
            // Title/message configured inside GFAlertVC via properties
            // We can rely on internal labels being configured in viewDidLoad
            _ = alert.view
            #expect(alert.titleLabel.text == "Empty Username")
            #expect(alert.messageLabel.text == "Please enter a username. We need to know who to look for 😀.")
            #expect(alert.actionButton.titleLabel?.text == "Ok")
        }
    }


    // US-003: Dismiss Keyboard
    // Screen: SearchVC
    // Priority: medium
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Keyboard dismisses when user taps outside text field
        - Text field loses focus
        - Keyboard animation is smooth
    */
    @Test("US-003: Dismiss Keyboard")
    func testDismissKeyboard() throws {
        let vc = SearchVC()
        _ = vc.view
        let gestures = vc.view.gestureRecognizers ?? []
        let hasTap = gestures.contains { -- is UITapGestureRecognizer }
        #expect(hasTap)
    }


    // US-004: Clear Text Field on Return
    // Screen: SearchVC
    // Priority: medium
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Text field is empty when returning to SearchVC
        - Previous search text is cleared
        - Text field is ready for new input
    */
    @Test("US-004: Clear Text Field on Return")
    func testClearTextFieldOnReturn() throws {
        let nav = UINavigationController(rootViewController: UIViewController())
        let search = SearchVC()
        nav.pushViewController(search, animated: false)

        _ = search.view
        search.usernameTextField.text = "octocat"
        search.viewWillAppear(false)
        #expect((search.usernameTextField.text ?? "").isEmpty)
    }


    // US-005: View Followers in Grid
    // Screen: FollowerListVC
    // Priority: high
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Followers are displayed in a 3-column grid
        - Each follower shows avatar image and username
        - Grid layout adapts to different screen sizes
    */
    @Test("US-005: View Followers in Grid")
    func testViewFollowersInGrid() throws {
        let vc = FollowerListVC(username: "octocat")
        _ = vc.view // triggers viewDidLoad
        #expect(vc.collectionView != nil)
        #expect(vc.dataSource != nil)

        // Assert flow layout columns: item width derived from UIHelper
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
    // Screen: FollowerListVC
    // Priority: high
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Search bar appears in navigation
        - Search filters followers in real-time
        - Search is case-insensitive
        - Empty search shows all followers
    */
    @Test("US-006: Search Through Followers")
    func testSearchThroughFollowers() throws {
        let vc = FollowerListVC(username: "octocat")
        _ = vc.view

        // Seed followers list directly and configure data source
        vc.followers = [
            Follower(login: "Alice", avatarUrl: ""),
            Follower(login: "bob", avatarUrl: ""),
            Follower(login: "Charlie", avatarUrl: "")
        ]
        vc.configureCollectionView()
        vc.configureDataSource()

        // Create a search controller and apply filter 'bo' (should match 'bob')
        let searchController = UISearchController()
        searchController.searchBar.text = "Bo"
        vc.updateSearchResults(for: searchController)

        #expect(vc.isSearching)
        #expect(vc.filteredFollowers.count == 1)
        #expect(vc.filteredFollowers.first?.login == "bob")
    }


    // US-007: Empty State for No Followers
    // Screen: FollowerListVC
    // Priority: medium
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Empty state view appears when no followers
        - Shows 'No Followers' message
        - Shows 'This user has no followers. Go follow them!' subtitle
    */
    @Test("US-007: Empty State for No Followers")
    func testEmptyStateForNoFollowers() throws {
        let vc = FollowerListVC(username: "someone")
        _ = vc.view

        // Ensure no loading in progress and no followers
        vc.isLoadingMoreFollowers = false
        vc.followers = []
        vc.updateUI(with: [])
        vc.updateContentUnavailableConfiguration(using: vc.contentUnavailableConfigurationState)
        
        // Assert: Verify the content unavailable configuration
        guard let config = vc.contentUnavailableConfiguration as? UIContentUnavailableConfiguration else {
            #expect(Bool(false), "Expected UIContentUnavailableConfiguration, but got \(String(describing: vc.contentUnavailableConfiguration))")
            return
        }
        
        #expect(config.text == "No Followers")
        #expect(config.secondaryText == "This user has no followers. Go follow them!")
    }


    // US-008: Selecting Follower Opens User Info
    // Screen: FollowerListVC -> UserInfoVC
    // Priority: high
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Tapping follower cell presents UserInfoVC
        - UserInfoVC shows selected user's info
        - Presentation is modal inside navigation controller
    */
    @Test("US-008: Selecting Follower Opens User Info")
    func testSelectingFollowerOpensUserInfo() throws {
        let vc = FollowerListVC(username: "octocat")
        let window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        _ = vc.view

        // Seed one follower and configure data source
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
    // Screen: FavoritesListVC
    // Priority: medium
    // TestType: ui_automation
    // Acceptance Criteria:
    /*
        - Empty state view appears when no favorites
        - Shows 'No Favorites' message
        - Shows 'Add a favorite on the follower list screen' subtitle
    */
    @Test("US-009: Empty Favorites State")
    func testEmptyFavoritesState() throws {
        // Arrange: Set up the view controller
        let vc = FavoritesListVC()
        
        // Trigger view lifecycle to ensure viewDidLoad and other setup methods are called
        vc.loadViewIfNeeded()
        
        // Act: Set favorites to empty and update the UI
        vc.favorites = []
        vc.updateUI(with: [])
        
        // Ensure the configuration update is processed
        vc.updateContentUnavailableConfiguration(using: vc.contentUnavailableConfigurationState)
        
        // Assert: Verify the content unavailable configuration
        guard let config = vc.contentUnavailableConfiguration as? UIContentUnavailableConfiguration else {
            #expect(Bool(false), "Expected UIContentUnavailableConfiguration, but got \(String(describing: vc.contentUnavailableConfiguration))")
            return
        }
        
        // Verify configuration properties
        #expect(config.text == "No Favorites")
        #expect(config.secondaryText == "Add a favorite on the follower list screen", "Secondary text should match expected value")
    }


}
