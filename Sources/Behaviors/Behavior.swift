import Aftermath

public protocol Behavior: ReactionProducer, CommandProducer {
  func extend(_ controller: AftermathController)
}
