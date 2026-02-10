extends TargetingStrategy
class_name InputTargetStrategy

## 输入目标策略
## 适用于：直接使用输入目标（input_target）作为最终目标的场景
## 也就是“指哪打哪”，不需要额外的索敌逻辑

func _resolve_targets(instigator: Node, input_target: Node, context: Dictionary) -> Array[Node]:
	var targets: Array[Node] = []
	if is_instance_valid(input_target):
		targets.append(input_target)
	return targets

func _get_description() -> String:
	return "Input Target (直接使用输入目标)"
