import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.setBorder(width: 1, colorName: "ypGray")

        setupTabBarItems()
    }

    private func setupTabBarItems() {
        let trackerController = UINavigationController(rootViewController: TrackersViewController())
        let statisticController = UINavigationController(rootViewController: StatisticsViewController())

        trackerController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "record.circle.fill"),
            tag: 0
        )
        statisticController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "hare.fill"),
            tag: 1
        )
        viewControllers = [trackerController, statisticController]
    }
}
