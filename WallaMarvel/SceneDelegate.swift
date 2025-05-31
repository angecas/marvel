import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
       
        let appCoordinator = AppCoordinator()
        self.appCoordinator = appCoordinator
        appCoordinator.start()

        window.rootViewController = appCoordinator.getRootViewController()
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}
