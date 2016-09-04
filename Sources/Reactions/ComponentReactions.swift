import Spots
import Aftermath

public struct ComponentReloadBuilder: ReactionBuilder {

  public weak var controller: SpotsController?

  // MARK: - Initialization

  public init(controller: SpotsController) {
    self.controller = controller
  }

  // MARK: - Reaction Builder

  public func buildReaction() -> Reaction<[Component]> {
    return Reaction(
      progress: {
        self.controller?.refreshControl.beginRefreshing()
      },
      done: { (components: [Component]) in
        self.controller?.reloadIfNeeded(components)
      },
      fail: { error in
        // Show error
      },
      complete: {
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}
