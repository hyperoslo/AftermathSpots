import UIKit
import Spots
import Brick
import Aftermath

public enum AfterMathRefreshMode {
  case Always, OnlyWhenEmpty, Disabled
}

public enum SpotsFeature {
  case PullToRefresh

  static let allValues = [PullToRefresh]
}

public class AftermathController: SpotsController, CommandProducer {

  let initialCommand: AnyCommand?
  var behaviors = [Behavior]()

  public var refreshMode: AfterMathRefreshMode = .OnlyWhenEmpty
  public var refreshOnViewDidAppear: Bool = true
  public var enabledFeatures: [SpotsFeature] = [.PullToRefresh] {
    didSet { toggle(features: enabledFeatures) }
  }

  public var errorHandler: ((error: ErrorType) -> Void)?

  // MARK: - Initialization

  public required init(cacheKey: String? = nil, spots: [Spotable] = [], initialCommand: AnyCommand? = nil, behaviors: [Behavior] = [], features: [SpotsFeature] = SpotsFeature.allValues) {
    var stateCache: SpotCache? = nil
    var cachedSpots: [Spotable] = spots

    if let cacheKey = cacheKey {
      stateCache = SpotCache(key: cacheKey)
      cachedSpots = Parser.parse(stateCache!.load())
    }

    self.initialCommand = initialCommand
    self.behaviors = behaviors
    super.init()
    self.stateCache = stateCache
    self.spots = cachedSpots
    self.enabledFeatures = features

    for behavior in behaviors {
      behavior.extend(self)
    }
  }

  public convenience init<T: Command where T.Output == [Component]>(cacheKey: String? = nil, componentCommand: T, behaviors: [Behavior] = []) {
    self.init(cacheKey: cacheKey, initialCommand: componentCommand, behaviors: behaviors)
    ComponentReloadBehavior(commandType: T.self).extend(self)
  }

  public convenience init<T: Command where T.Output == [Item]>(cacheKey: String? = nil, spots: [Spotable], spotCommand: T, behaviors: [Behavior] = []) {
    self.init(cacheKey: cacheKey, spots: spots, initialCommand: spotCommand, behaviors: behaviors)
    SpotReloadBehavior(index: 0, commandType: T.self).extend(self)
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
    toggle(features: enabledFeatures)
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
    behaviors.forEach {
      $0.disposeAll()
    }
  }

  func toggle(features features: [SpotsFeature]) {
    for feature in SpotsFeature.allValues {
      switch feature {
      case .PullToRefresh:
        spotsRefreshDelegate = features.contains(feature) ? self : nil
      }
    }
  }
}

extension AftermathController: SpotsRefreshDelegate {

  public func spotsDidReload(refreshControl: UIRefreshControl, completion: Completion) {
    executeInitial()
    completion?()
  }
}
