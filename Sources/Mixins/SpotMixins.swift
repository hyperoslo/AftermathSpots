import Aftermath
import Spots
import Brick

public struct SpotReloadMixin<R: Command where R.Output == [ViewModel]>: Mixin {

  public let index: Int
  public let reload: R

  public init(index: Int, reload: R) {
    self.index = index
    self.reload = reload
  }

  public func extend(controller: AftermathController) {
    react(to: R.self, with: SpotReloadBuilder(index: index, controller: controller).buildReaction())
  }
}
