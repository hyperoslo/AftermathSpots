import Aftermath
import Spots

// MARK: - Reload components

public struct ComponentReloadMixin<T: Command where T.Output == [Component]>: Mixin {

  public let commandType: T.Type

  public init(commandType: T.Type) {
    self.commandType = commandType
  }

  public func extend(controller: AftermathController) {
    react(to: commandType, with: ComponentReloadBuilder(controller: controller).buildReaction())
  }
}
