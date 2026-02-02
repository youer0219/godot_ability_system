@abstract
extends GameplayAbilitySystem.BTNode

@export var child: GameplayAbilitySystem.BTNode

func reset(instance: GameplayAbilitySystem.BTInstance) -> void:
	_clear_storage(instance)
	if is_instance_valid(child):
		child.reset(instance)

func _tick(instance: GameplayAbilitySystem.BTInstance, delta: float) -> int:
	if not is_instance_valid(child):
		return Status.FAILURE
	
	return _tick_decorator(instance, delta)

# 子类实现具体逻辑
func _tick_decorator(instance: GameplayAbilitySystem.BTInstance, delta: float) -> int:
	return child.tick(instance, delta)
