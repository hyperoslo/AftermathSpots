import Aftermath

public protocol Behavior: ReactionProducer, CommandProducer {
  func extend(_ controller: AftermathController)
}

public protocol PreAppearingBehavior {
  func behaviorWillAppear(in controller: AftermathController)
}

public protocol PreDisappearingBehavior {
  func behaviorWillDisappear(in controller: AftermathController)
}

public protocol PostAppearingBehavior {
  func behaviorDidAppear(in controller: AftermathController)
}

public protocol PostDisappearingBehavior {
  func behaviorDidDisappear(in controller: AftermathController)
}
