import UIKit
import Spots
import Brick
import Aftermath

public enum AfterMathRefreshMode {
  case always, onlyWhenEmpty, disabled
}

public enum SpotsFeature {
  case PullToRefresh

  static let allValues = [PullToRefresh]
}

open class AftermathController: Spots.Controller, CommandProducer {

  let initialCommand: AnyCommand?
  var behaviors = [Behavior]()

  public var refreshMode: AfterMathRefreshMode = .disabled
  public var refreshOnViewDidAppear: Bool = true
  public var enabledFeatures: [SpotsFeature] = [.PullToRefresh] {
    didSet { toggle(features: enabledFeatures) }
  }

  public var errorHandler: ((_ error: Error) -> Void)?

  // MARK: - Initialization

  public required init(cacheKey: String? = nil, spots: [Spotable] = [], initialCommand: AnyCommand? = nil, behaviors: [Behavior] = [], features: [SpotsFeature] = SpotsFeature.allValues) {
    var stateCache: StateCache? = nil
    var cachedSpots: [Spotable] = spots

    if let cacheKey = cacheKey {
      stateCache = StateCache(key: cacheKey)
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

  public convenience init<T: Command>(cacheKey: String? = nil, componentCommand: T, behaviors: [Behavior] = []) where T.Output == [Component] {
    self.init(cacheKey: cacheKey, initialCommand: componentCommand, behaviors: behaviors)
    let componentReloadBehavior = ComponentReloadBehavior(commandType: T.self)
    componentReloadBehavior.extend(self)
    self.behaviors.append(componentReloadBehavior)
  }

  public convenience init<T: Command>(cacheKey: String? = nil, spots: [Spotable], spotCommand: T, behaviors: [Behavior] = []) where T.Output == [Item] {
    self.init(cacheKey: cacheKey, spots: spots, initialCommand: spotCommand, behaviors: behaviors)
    let reloadBehavior = SpotReloadBehavior(index: 0, commandType: T.self)
    reloadBehavior.extend(self)
    self.behaviors.append(reloadBehavior)
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

  open override func viewDidLoad() {
    super.viewDidLoad()
    toggle(features: enabledFeatures)
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    executeInitial()

    for case let behavior as PreAppearingBehavior in behaviors {
      behavior.behaviorWillAppear(in: self)
    }
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    for case let behavior as PostAppearingBehavior in behaviors {
      behavior.behaviorDidAppear(in: self)
    }
  }

  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    for case let behavior as PreDisappearingBehavior in behaviors {
      behavior.behaviorWillDisappear(in: self)
    }
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    for case let behavior as PostDisappearingBehavior in behaviors {
      behavior.behaviorDidDisappear(in: self)
    }
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

  func toggle(features: [SpotsFeature]) {
    for feature in SpotsFeature.allValues {
      switch feature {
      case .PullToRefresh:
        refreshDelegate = features.contains(feature) ? self : nil
      }
    }
  }
}

extension AftermathController: Spots.RefreshDelegate {

  public func spotsDidReload(_ refreshControl: UIRefreshControl, completion: Completion) {
    executeInitial()
    completion?()
  }
}
