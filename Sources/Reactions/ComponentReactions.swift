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

  public func buildReaction() -> Reaction<[ComponentModel]> {
    return Reaction(
      wait: {
        guard self.controller?.refreshMode != .disabled else { return }

        if self.controller?.refreshMode == .always {
          self.controller?.refreshControl.beginRefreshing()
        } else if self.controller?.refreshMode == .onlyWhenEmpty &&
          self.controller?.components.isEmpty == true {
          self.controller?.refreshControl.beginRefreshing()
        }
    },
      consume: { (components: [ComponentModel]) in
        guard let controller = self.controller, controller.refreshOnViewDidAppear else { return }

        controller.reloadIfNeeded(components, compare: controller.viewModelComparison) {
          Spots.Controller.componentsDidReloadComponentModels?(controller)
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
