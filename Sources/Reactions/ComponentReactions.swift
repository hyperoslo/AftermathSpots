import Spots
import Aftermath

// MARK: - Reload components

public struct ComponentReloadBuilder: ReactionBuilder {

  public weak var controller: AftermathController?

  public init(controller: AftermathController) {
    self.controller = controller
  }

  public func buildReaction() -> Reaction<[Component]> {
    return Reaction(
      wait: {
        self.controller?.refreshControl.beginRefreshing()
      },
      consume: { (components: [Component]) in
        self.controller?.reloadIfNeeded(components) {
          self.controller?.cache()
        }
        self.controller?.refreshControl.endRefreshing()
      },
      rescue: { error in
        self.controller?.errorHandler?(error: error)
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}
