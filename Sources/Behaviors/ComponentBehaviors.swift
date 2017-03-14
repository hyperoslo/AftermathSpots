import Aftermath
import Spots

// MARK: - Reload components

public struct ComponentReloadBehavior<T: Command>: Behavior where T.Output == [ComponentModel] {

  public let commandType: T.Type

  public init(commandType: T.Type) {
    self.commandType = commandType
  }

  public func extend(_ controller: AftermathController) {
    react(to: commandType, with: ComponentReloadBuilder(controller: controller).buildReaction())
  }
}
