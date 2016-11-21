import Spots
import Aftermath
import Foundation

// MARK: - Reload components

public struct ComponentReloadBuilder: ReactionBuilder {

  public weak var controller: AftermathController?

  public init(controller: AftermathController) {
    self.controller = controller
  }

  fileprivate func stopReloading() {
    if self.controller?.refreshControl.isRefreshing == true {
      DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: {
          self.controller?.refreshControl.endRefreshing()
        }
      )
    }
  }

  public func buildReaction() -> Reaction<[Component]> {

    return Reaction(
      wait: {
        guard self.controller?.refreshMode != .Disabled else { return }

        if self.controller?.refreshMode == .Always {
          self.controller?.refreshControl.beginRefreshing()
        } else if self.controller?.refreshMode == .OnlyWhenEmpty &&
          self.controller?.spots.isEmpty == true {
          self.controller?.refreshControl.beginRefreshing()
        }
      },
      consume: { (components: [Component]) in
        guard self.controller?.refreshOnViewDidAppear == true else { return }

        self.controller?.reloadIfNeeded(components, compare: { $0 != $1 }) {
          if let controller = self.controller as? Spots.Controller {
            Spots.Controller.spotsDidReloadComponents?(controller)
          }

          self.controller?.cache()
        }
        self.stopReloading()
      },
      rescue: { error in
        self.controller?.errorHandler?(error)
        self.stopReloading()
      }
    )
  }
}
