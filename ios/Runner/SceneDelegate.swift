import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  // A tap on the Live Activity opens "bebometro://outing/<id>?action=...". The
  // link is only stored; Flutter asks for it and confirms before registering.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts {
      TrackingChannel.shared.handle(url: context.url)
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    for context in URLContexts {
      TrackingChannel.shared.handle(url: context.url)
    }
  }
}
