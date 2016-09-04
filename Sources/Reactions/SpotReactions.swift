import Spots
import Brick
import Aftermath

public struct SpotReloadBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: SpotsController?

  // MARK: - Initialization

  public init(index: Int, controller: SpotsController) {
    self.index = index
    self.controller = controller
  }

  // MARK: - Reaction Builder

  public func buildReaction() -> Reaction<[ViewModel]> {
    return Reaction(
      progress: {
        self.controller?.refreshControl.beginRefreshing()
      },
      done: { (viewModels: [ViewModel]) in
        self.controller?.spot(self.index, Spotable.self)?.reloadIfNeeded(viewModels)
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
