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
      progress: {
        self.controller?.refreshControl.beginRefreshing()
      },
      done: { (components: [Component]) in
        self.controller?.reloadIfNeeded(components) {
          self.controller?.cache()
        }
      },
      fail: { error in
        self.controller?.errorHandler?(error: error)
      },
      complete: {
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}
