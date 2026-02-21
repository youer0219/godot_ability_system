extends GameplayAbilityFeature
class_name ActionSpeedFeature

## 动作速度特性
## 根据角色的属性（如攻速）动态调整技能执行速度（时间缩放）
## 影响：动画播放速度、等待时间（Wait节点）

## 行动速度属性名称
## 该属性的值将被用作时间缩放倍率 (scale = 属性值)
## 例如: 属性值为 1.5 表示动作速度加快 50%
@export var action_speed_attribute_name: StringName = &"attack_speed"

@export var min_scale: float = 0.1 ## 最小缩放倍率
@export var max_scale: float = 5.0 ## 最大缩放倍率

func on_activate(ability: GameplayAbilityInstance, context: Dictionary) -> void:
	var instigator = context.get("instigator")
	if not is_instance_valid(instigator):
		return
	
	var scale: float = 1.0
	
	# 尝试获取属性组件
	var attr_comp = GameplayAbilitySystem.get_component_by_interface(instigator, "GameplayVitalAttributeComponent")
	if is_instance_valid(attr_comp):
		var current_val = attr_comp.get_value(action_speed_attribute_name, 1.0)
		scale = current_val
	
	# 限制范围
	scale = clampf(scale, min_scale, max_scale)
	
	# 注入 Context
	context["time_scale"] = scale
	
	# 注入 Blackboard (供行为树节点使用)
	if is_instance_valid(ability.get_blackboard()):
		ability.set_blackboard_var("time_scale", scale)
