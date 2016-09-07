import Spots
import Aftermath
import Sugar

// MARK: - Reload components

public struct ComponentReloadBuilder: ReactionBuilder {

  public weak var controller: AftermathController?

  public init(controller: AftermathController) {
    self.controller = controller
  }

  private func stopReloading() {
    if self.controller?.refreshControl.refreshing == true {
      delay(0.1) { self.controller?.refreshControl.endRefreshing() }
    }
  }

  public func buildReaction() -> Reaction<[Component]> {

    return Reaction(
      wait: {
        guard self.controller?.refreshBehaviour != .Disabled else { return }

        if self.controller?.refreshBehaviour == .Always {
          self.controller?.refreshControl.beginRefreshing()
        } else if self.controller?.refreshBehaviour == .OnlyWhenEmpty &&
          self.controller?.spots.isEmpty == true {
          self.controller?.refreshControl.beginRefreshing()
        }
      },
      consume: { (components: [Component]) in
        self.controller?.reloadIfNeeded(components) {
          self.controller?.cache()
        }
        self.stopReloading()
      },
      rescue: { error in
        self.controller?.errorHandler?(error: error)
        self.stopReloading()
      }
    )
  }
}
