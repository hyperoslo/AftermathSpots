import UIKit
import Spots
import Brick
import Aftermath

public enum AfterMathRefreshBehaviour {
  case Always, OnlyWhenEmpty, Disabled
}

public class AftermathController: SpotsController, CommandProducer {

  let initialCommand: AnyCommand?
  var mixins = [Mixin]()
  var refreshBehaviour: AfterMathRefreshBehaviour = .OnlyWhenEmpty

  public var errorHandler: ((error: ErrorType) -> Void)?

  // MARK: - Initialization

  public required init(cacheKey: String? = nil, spots: [Spotable] = [], initialCommand: AnyCommand? = nil, mixins: [Mixin] = []) {
    var stateCache: SpotCache? = nil
    var cachedSpots: [Spotable] = spots
    if let cacheKey = cacheKey {
      stateCache = SpotCache(key: cacheKey)
      cachedSpots = Parser.parse(stateCache!.load())
    }

    self.initialCommand = initialCommand
    self.mixins = mixins
    super.init()
    self.stateCache = stateCache
    self.spots = cachedSpots

    for mixin in mixins {
      mixin.extend(self)
    }
  }

  public convenience init<T: Command where T.Output == [Component]>(cacheKey: String? = nil, componentCommand: T, mixins: [Mixin] = []) {
    self.init(cacheKey: cacheKey, initialCommand: componentCommand, mixins: mixins)
    ComponentReloadMixin(commandType: T.self).extend(self)
  }

  public convenience init<T: Command where T.Output == [ViewModel]>(cacheKey: String? = nil, spots: [Spotable], spotCommand: T, mixins: [Mixin] = []) {
    self.init(cacheKey: cacheKey, spots: spots, initialCommand: spotCommand, mixins: mixins)
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

    executeInitial()
  }

  public func executeInitial() {
    if let initialCommand = initialCommand {
      execute(command: initialCommand)
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
