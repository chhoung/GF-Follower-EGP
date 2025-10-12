
// GeneratedUserStoryTests.swift, AUTO-GENERATED, Copyright © 2025 Kimchhorng Pheng

import Testing
import UIKit
@testable import GHFollowers

@MainActor
struct GeneratedUserStoryTests {

    // US-001: Search for GitHub User
    @Test("US-001: Search for GitHub User")
    func testSearchForGitHubUser() {
        /* 
        - User can enter a username in the text field
        - User can tap 'Get Followers' button to search
        - User can press return key to submit search
        - App navigates to follower list screen on successful search
        */
        
        let vc = SearchVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        vc.usernameTextField.text = "octocat"
        vc.callToActionButton.sendActions(for: .touchUpInside)

        RunLoop.current.run()

        guard let followerListVC = navigationController.topViewController as? FollowerListVC else {
            Issue.record("Expected to navigate to FollowerListVC")
            return
        }
        
        #expect(followerListVC.isMovingToParentViewController).to(beTrue())
    }

    // US-002: Handle Empty Username Search
    @Test("US-002: Handle Empty Username Search")
    func testHandleEmptyUsernameSearch() {
        /* 
        - Alert appears when 'Get Followers' is tapped with empty text field
        - Alert shows title 'Empty Username'
        - Alert shows message 'Please enter a username. We need to know who to look for 😀.'
        - Alert has 'Ok' button to dismiss
        */
        
        let vc = SearchVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        vc.callToActionButton.sendActions(for: .touchUpInside)

        RunLoop.current.run()

        guard let alert = vc.presentedViewController as? UIAlertController else {
            Issue.record("Expected an alert to be presented")
            return
        }

        #expect(alert.title).to(equal("Empty Username"))
        #expect(alert.message).to(equal("Please enter a username. We need to know who to look for 😀."))
    }

    // US-003: Dismiss Keyboard
    @Test("US-003: Dismiss Keyboard")
    func testDismissKeyboard() {
        /* 
        - Keyboard dismisses when user taps outside text field
        - Text field loses focus
        - Keyboard animation is smooth
        */
        
        let vc = SearchVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        vc.usernameTextField.becomeFirstResponder()

        RunLoop.current.run()

        vc.view.sendActions(for: .touchUpInside)

        RunLoop.current.run()

        #expect(vc.usernameTextField.isFirstResponder).to(beFalse())
    }

    // US-004: Clear Text Field on Return
    @Test("US-004: Clear Text Field on Return")
    func testClearTextFieldOnReturn() {
        /* 
        - Text field is empty when returning to SearchVC
        - Previous search text is cleared
        - Text field is ready for new input
        */
        
        let vc = SearchVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        vc.usernameTextField.text = "octocat"
        
        vc.usernameTextField.resignFirstResponder()
        vc.viewWillAppear(false)
        
        #expect(vc.usernameTextField.text).to(beEmpty())
    }

    // US-005: View Followers in Grid
    @Test("US-005: View Followers in Grid")
    func testViewFollowersInGrid() {
        /* 
        - Followers are displayed in a 3-column grid
        - Each follower shows avatar image and username
        - Grid layout adapts to different screen sizes
        */
        
        let vc = FollowerListVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        
        vc.followers = [Follower(login: "octocat", avatarUrl: "http://example.com/avatar.png")]
        vc.collectionView.reloadData()
        
        RunLoop.current.run()

        #expect(vc.collectionView.numberOfItems(inSection: 0)).to(equal(1))
        
        let cell = vc.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? FollowerCell
        #expect(cell?.usernameLabel.text).to(equal("octocat"))
    }

    // US-006: Search Through Followers
    @Test("US-006: Search Through Followers")
    func testSearchThroughFollowers() {
        /* 
        - Search bar appears in navigation
        - Search filters followers in real-time
        - Search is case-insensitive
        - Empty search shows all followers
        */
        
        let vc = FollowerListVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view

        let follower = Follower(login: "octocat", avatarUrl: "http://example.com/avatar.png")
        vc.followers = [follower]
        vc.collectionView.reloadData()
        
        RunLoop.current.run()

        vc.searchController.searchBar.text = "octocat"
        vc.searchController.searchBar.sendActions(for: .valueChanged)

        RunLoop.current.run()

        #expect(vc.filteredFollowers.count).to(equal(1))
        #expect(vc.collectionView.numberOfItems(inSection: 0)).to(equal(1))
    }

    // US-007: Empty State for No Followers
    @Test("US-007: Empty State for No Followers")
    func testEmptyStateForNoFollowers() {
        /* 
        - Empty state view appears when no followers
        - Shows 'No Followers' message
        - Shows 'This user has no followers. Go follow them!' subtitle
        */
        
        let vc = FollowerListVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        
        vc.followers = []
        vc.collectionView.reloadData()
        
        RunLoop.current.run()

        guard vc.emptyStateView.isHidden == false else {
            Issue.record("Expected empty state view to be visible")
            return
        }

        #expect(vc.emptyStateView.messageLabel.text).to(equal("No Followers"))
        #expect(vc.emptyStateView.subtitleLabel.text).to(equal("This user has no followers. Go follow them!"))
    }

    // US-008: Selecting Follower Opens User Info
    @Test("US-008: Selecting Follower Opens User Info")
    func testSelectingFollowerOpensUserInfo() {
        /* 
        - Tapping follower cell presents UserInfoVC
        - UserInfoVC shows selected user's info
        - Presentation is modal inside navigation controller
        */
        
        let vc = FollowerListVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        
        let follower = Follower(login: "octocat", avatarUrl: "http://example.com/avatar.png")
        vc.followers = [follower]
        vc.collectionView.reloadData()
        
        RunLoop.current.run()

        vc.collectionView.delegate?.collectionView?(vc.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        
        RunLoop.current.run()
        
        guard let userInfoVC = navigationController.topViewController as? UserInfoVC else {
            Issue.record("Expected to navigate to UserInfoVC")
            return
        }

        #expect(userInfoVC.usernameLabel.text).to(equal("octocat"))
    }

    // US-009: Empty Favorites State
    @Test("US-009: Empty Favorites State")
    func testEmptyFavoritesState() {
        /* 
        - Empty state view appears when no favorites
        - Shows 'No Favorites' message
        - Shows 'Add a favorite on the follower list screen' subtitle
        */
        
        let vc = FavoritesListVC()
        let navigationController = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        _ = vc.view
        
        vc.favorites = []
        vc.collectionView.reloadData()
        
        RunLoop.current.run()

        guard vc.emptyStateView.isHidden == false else {
            Issue.record("Expected empty state view to be visible")
            return
        }

        #expect(vc.emptyStateView.messageLabel.text).to(equal("No Favorites"))
        #expect(vc.emptyStateView.subtitleLabel.text).to(equal("Add a favorite on the follower list screen"))
    }
}
