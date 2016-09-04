import Aftermath
import Spots

public struct ComponentReloadMixin<R: Command where R.Output == [Component]>: Mixin {

  public let reload: R

  public init(reload: R) {
    self.reload = reload
  }

  public func extend(controller: AftermathController) {
    react(to: R.self, with: ComponentReloadBuilder(controller: controller).buildReaction())
  }
}
