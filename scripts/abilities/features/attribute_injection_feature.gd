extends GameplayAbilityFeature
class_name AttributeInjectionFeature

## 属性注入特性
## 负责将角色的属性值（如攻击范围、暴击率、移动速度等）注入到技能上下文（Context）和黑板（Blackboard）中
## 使得后续的技能逻辑（如检测器、伤害计算、投射物生成）能够动态读取这些属性

@export var attribute_name: StringName = &"" ## 属性名
@export var context_key: String = "" ## 注入到 Context 的 Key

@export var default_value: float = 0.0 ## 默认值
@export var min_value: float = -INF ## 最小值限制
@export var max_value: float = INF ## 最大值限制

## 是否同时注入到黑板
@export var inject_to_blackboard: bool = false

## 属性组件名称，默认为 "GameplayVitalAttributeComponent"
@export var attribute_component_name: StringName = &"GameplayVitalAttributeComponent"

func _init() -> void:
	super("AttributeInjectionFeature")

func on_activate(ability: GameplayAbilityInstance, context: Dictionary) -> void:
	var instigator = context.get("instigator")
	if not is_instance_valid(instigator):
		return
	
	# 尝试获取属性组件
	var attr_comp = GameplayAbilitySystem.get_component_by_interface(instigator, attribute_component_name)
	if not is_instance_valid(attr_comp):
		return

	# 获取属性值
	var val = attr_comp.get_value(attribute_name, default_value)
	
	# 限制范围
	val = clampf(val, min_value, max_value)
	
	# 注入 Context
	context[context_key] = val
	
	# 注入 Blackboard
	if inject_to_blackboard and is_instance_valid(ability.get_blackboard()):
		ability.set_blackboard_var(context_key, val)
