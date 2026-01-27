extends Node

const BURN_STATUS = preload("uid://yjensy7cr6dj")

@onready var status_comp: GameplayStatusComponent = %GameplayStatusComponent

func _ready() -> void:
	await get_tree().process_frame
	# 应用并叠加燃烧
	var burn_status = BURN_STATUS.duplicate(true)
	status_comp.apply_status(burn_status, self, 1, {})
	status_comp.apply_status(burn_status, self, 1, {})
	var instance = status_comp.get_status(&"burn")
	print("燃烧层数:", instance.stacks)  # 期望 2

	# 按标签批量移除
	status_comp.remove_statuses_by_tags([&"status.burn"])
	assert(not status_comp.has_status(&"burn"))
	print("✅ 状态组件测试通过")
