import Spots
import Aftermath
import Sugar

// MARK: - Reload components

public struct ComponentReloadBuilder: ReactionBuilder {

  public weak var controller: AftermathController?

  public init(controller: AftermathController) {
    self.controller = controller
  }

  public func buildReaction() -> Reaction<[Component]> {
    return Reaction(
      progress: {
        guard self.controller?.refreshBehaviour != .Disabled else { return }

        if self.controller?.refreshBehaviour == .Always {
          self.controller?.refreshControl.beginRefreshing()
        } else if self.controller?.refreshBehaviour == .OnlyWhenEmpty &&
          self.controller?.spots.isEmpty == true {
          self.controller?.refreshControl.beginRefreshing()
        }
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
        if self.controller?.refreshControl.refreshing == true {
          delay(0.1) {
            self.controller?.refreshControl.endRefreshing()
          }
        }
      }
    )
  }
}
