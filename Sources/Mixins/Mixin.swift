import Aftermath

public protocol Mixin: ReactionProducer, CommandProducer {
  func extend(controller: AftermathController)
}
