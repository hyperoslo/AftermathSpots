import Spots
import Brick
import Aftermath

// MARK: - Reload spots

public struct SpotReloadBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<[Item]> {
    return Reaction(
      wait: {
        self.controller?.refreshControl.beginRefreshing()
      },
      consume: { (viewModels: [Item]) in
        self.controller?.spot(self.index, Spotable.self)?.reloadIfNeeded(viewModels)
        self.controller?.refreshControl.endRefreshing()
      },
      rescue: { error in
        self.controller?.errorHandler?(error: error)
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}

// MARK: - Insert view model

public enum Insert {
  case Append([Item])
  case Prepend([Item])
  case Index(Int, Item)
}

public struct SpotInsertBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<Insert> {
    return Reaction(
      consume: { (insert: Insert) in
        let spot = self.controller?.spot(self.index, Spotable.self)

        switch insert {
        case .Append(let viewModels):
          spot?.append(viewModels)
        case .Prepend(let viewModels):
          spot?.prepend(viewModels)
        case .Index(let index, let viewModel):
          spot?.insert(viewModel, index: index)
        }
      },
      rescue: { error in
        self.controller?.errorHandler?(error: error)
      }
    )
  }
}

// MARK: - Update view model at index

public struct SpotUpdateBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<Item> {
    return Reaction(
      consume: { (viewModel: Item) in
        guard let items = self.controller?.spot(self.index, Spotable.self)?.items,
          itemIndex = items.indexOf({ $0.identifier == viewModel.identifier })
          else { return }

        self.controller?.spot(self.index, Spotable.self)?.update(viewModel, index: itemIndex)
      },
      rescue: { error in
        self.controller?.errorHandler?(error: error)
      }
    )
  }
}

// MARK: - Delete view model at index

public struct SpotDeleteBuilder: ReactionBuilder {

  public let index: Int
  public weak var controller: AftermathController?

  public init(index: Int, controller: AftermathController) {
    self.index = index
    self.controller = controller
  }

  public func buildReaction() -> Reaction<Item> {
    return Reaction(
      consume: { (viewModel: Item) in
        guard let items = self.controller?.spot(self.index, Spotable.self)?.items,
          itemIndex = items.indexOf({ $0.identifier == viewModel.identifier })
          else { return }

        self.controller?.spot(self.index, Spotable.self)?.delete(itemIndex)
      },
      rescue: { error in
        self.controller?.errorHandler?(error: error)
      }
    )
  }
}
