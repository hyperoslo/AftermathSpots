import Aftermath

public protocol Behavior: ReactionProducer, CommandProducer {
  func extend(controller: AftermathController)
}
