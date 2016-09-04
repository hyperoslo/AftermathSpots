import Aftermath
import Spots
import Brick

// MARK: - Reload spots

public struct SpotReloadMixin<T: Command where T.Output == [ViewModel]>: Mixin {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(controller: AftermathController) {
    react(to: commandType, with: SpotReloadBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Insert view model

public struct SpotInsertMixin<T: Command where T.Output == Insert>: Mixin {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(controller: AftermathController) {
    react(to: commandType, with: SpotInsertBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Update view model at index

public struct SpotUpdateMixin<T: Command where T.Output == ViewModel>: Mixin {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(controller: AftermathController) {
    react(to: commandType, with: SpotUpdateBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Delete view model at index

public struct SpotDeleteMixin<T: Command where T.Output == ViewModel>: Mixin {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(controller: AftermathController) {
    react(to: commandType, with: SpotDeleteBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Infinite scrolling

public class SpotScrollingMixin<T: Command where T.Output == Insert>: Mixin {

  public let index: Int
  public let command: T

  public init(index: Int, command: T) {
    self.index = index
    self.command = command
  }

  public func extend(controller: AftermathController) {
    react(to: T.self, with: SpotInsertBuilder(index: index, controller: controller).buildReaction())
  }
}

extension SpotScrollingMixin: SpotsScrollDelegate {

  public func spotDidReachEnd(completion: Completion) {
    execute(command)
  }
}
