import Spots
import Aftermath

// MARK: - Reload components

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
        self.controller?.component(at: self.index)?.reloadIfNeeded(viewModels)
        self.controller?.refreshControl.endRefreshing()
      },
      rescue: { error in
        self.controller?.errorHandler?(error)
        self.controller?.refreshControl.endRefreshing()
      }
    )
  }
}

// MARK: - Insert view model

public enum Insert {
  case append([Item])
  case prepend([Item])
  case index(Int, Item)
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
        let component = self.controller?.component(at: self.index)

        switch insert {
        case .append(let viewModels):
          component?.append(viewModels)
        case .prepend(let viewModels):
          component?.prepend(viewModels)
        case .index(let index, let viewModel):
          component?.insert(viewModel, index: index)
        }
      },
      rescue: { error in
        self.controller?.errorHandler?(error)
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
        guard let items = self.controller?.component(at: self.index)?.items,
          let itemIndex = items.index(where: { $0.identifier == viewModel.identifier })
          else { return }

        self.controller?.component(at: self.index)?.update(viewModel, index: itemIndex)
      },
      rescue: { error in
        self.controller?.errorHandler?(error)
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
        guard let items = self.controller?.component(at: self.index)?.items,
          let itemIndex = items.index(where: { $0.identifier == viewModel.identifier })
          else { return }

        self.controller?.component(at: self.index)?.delete(itemIndex)
      },
      rescue: { error in
        self.controller?.errorHandler?(error)
      }
    )
  }
}
