import Aftermath
import Spots

// MARK: - Reload components

public struct SpotReloadBehavior<T: Command>: Behavior where T.Output == [Item] {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(_ controller: AftermathController) {
    react(to: commandType, with: SpotReloadBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Insert view model

public struct SpotInsertBehavior<T: Command>: Behavior where T.Output == Insert {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(_ controller: AftermathController) {
    react(to: commandType, with: SpotInsertBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Update view model at index

public struct SpotUpdateBehavior<T: Command>: Behavior where T.Output == Item {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(_ controller: AftermathController) {
    react(to: commandType, with: SpotUpdateBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Delete view model at index

public struct SpotDeleteBehavior<T: Command>: Behavior where T.Output == Item {

  public let index: Int
  public let commandType: T.Type

  public init(index: Int, commandType: T.Type) {
    self.index = index
    self.commandType = commandType
  }

  public func extend(_ controller: AftermathController) {
    react(to: commandType, with: SpotDeleteBuilder(index: index, controller: controller).buildReaction())
  }
}

// MARK: - Infinite scrolling

open class SpotScrollingBehavior<T: Command>: Behavior where T.Output == Insert {

  open let index: Int
  open let command: T

  public init(index: Int, command: T) {
    self.index = index
    self.command = command
  }

  open func extend(_ controller: AftermathController) {
    controller.scrollDelegate = self
    react(to: T.self, with: SpotInsertBuilder(index: index, controller: controller).buildReaction())
  }
}

extension SpotScrollingBehavior: Spots.ScrollDelegate {

  public func didReachEnd(in scrollView: ScrollableView, completion: Completion) {
    execute(command: command)
  }
}
