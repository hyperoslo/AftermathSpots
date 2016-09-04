import UIKit
import Spots
import Brick
import Aftermath

public class AftermathController: SpotsController, CommandProducer {

  let initialCommand: AnyCommand?
  var mixins = [Mixin]()

  public var errorHandler: ((error: ErrorType) -> Void)?

  // MARK: - Initialization

  public required init(initialCommand: AnyCommand? = nil, mixins: [Mixin] = []) {
    self.initialCommand = initialCommand
    self.mixins = mixins

    super.init(spots: [])

    for mixin in mixins {
      mixin.extend(self)
    }
  }

  public convenience init<T: Command where T.Output == [Component]>(componentCommand: T, mixins: [Mixin] = []) {
    self.init(initialCommand: componentCommand, mixins: mixins)
    ComponentReloadMixin(commandType: T.self).extend(self)
  }

  public convenience init<T: Command where T.Output == [ViewModel]>(spotCommand: T, mixins: [Mixin] = []) {
    self.init(initialCommand: spotCommand, mixins: mixins)
    SpotReloadMixin(index: 0, commandType: T.self).extend(self)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public required init(spots: [Spotable]) {
    fatalError("init(spots:) has not been implemented")
  }

  deinit {
    disposeReactions()
  }

  // MARK: - View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()
    spotsRefreshDelegate = self
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let initialCommand = initialCommand {
      execute(initialCommand)
    }
  }

  public func executeInitial() {
    if let initialCommand = initialCommand {
      execute(initialCommand)
    }
  }

  public func disposeReactions() {
    mixins.forEach {
      $0.disposeAll()
    }
  }
}

extension AftermathController: SpotsRefreshDelegate {

  public func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    executeInitial()
    completion?()
  }
}
