import Aftermath
import Spots
import Brick

// MARK: - Reload spots

public struct SpotReloadBehavior<T: Command where T.Output == [ViewModel]>: Behavior {

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

public struct SpotInsertBehavior<T: Command where T.Output == Insert>: Behavior {

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

public struct SpotUpdateBehavior<T: Command where T.Output == ViewModel>: Behavior {

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

public struct SpotDeleteBehavior<T: Command where T.Output == ViewModel>: Behavior {

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

public class SpotScrollingBehavior<T: Command where T.Output == Insert>: Behavior {

  public let index: Int
  public let command: T

  public init(index: Int, command: T) {
    self.index = index
    self.command = command
  }

  public func extend(controller: AftermathController) {
    controller.spotsScrollDelegate = self
    react(to: T.self, with: SpotInsertBuilder(index: index, controller: controller).buildReaction())
  }
}

extension SpotScrollingBehavior: SpotsScrollDelegate {

  public func spotDidReachEnd(completion: Completion) {
    execute(command: command)
  }
}
