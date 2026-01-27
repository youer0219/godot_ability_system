# 状态系统指南

## 概述

状态系统（Status System）负责管理游戏中的 Buff 和 Debuff，包括状态的叠加、持续时间、效果应用等。

## 核心概念

### 状态数据（Status Data）

状态数据是状态的静态定义，包含状态的所有配置信息。

**主要属性：**
- `status_id`: 状态唯一标识符
- `status_display_name`: 显示名称
- `duration`: 持续时间（-1 为永久，0 为瞬时，>0 为持续时间）
- `duration_policy`: 持续时间策略
- `stacking_policy`: 叠加策略
- `max_stacks`: 最大叠加层数
- `priority`: 状态优先级
- `tags`: 状态标签
- `apply_effects`: 应用时的效果列表
- `remove_effects`: 移除时的效果列表
- `features`: 状态特性列表

### 状态实例（Status Instance）

状态实例是状态的运行时对象，包含状态的当前状态信息。

**包含：**
- 层数（Stacks）
- 剩余时间（Remaining Time）
- 应用时间（Apply Time）
- 状态数据引用

### 状态组件（Status Component）

状态组件管理角色身上的所有状态。

**功能：**
- 应用状态
- 移除状态
- 查询状态
- 更新状态（持续时间、周期性效果）

## 状态叠加策略

### 1. 刷新持续时间（Refresh Duration）

新状态刷新已有状态的持续时间，不叠加层数。

**适用场景：** 大多数 Buff/Debuff

```gdscript
var policy = StackingRefreshDuration.new()
status_data.stacking_policy = policy
status_data.max_stacks = 1
```

### 2. 叠加层数（Stack Intensity）

新状态增加层数，每层独立计算效果。

**适用场景：** 可叠加的 Buff/Debuff

```gdscript
var policy = StackingIntensity.new()
status_data.stacking_policy = policy
status_data.max_stacks = 10
```

### 3. 刷新并叠加（Refresh and Stack）

新状态刷新持续时间并增加层数。

**适用场景：** 需要同时叠加和刷新的状态

```gdscript
var policy = StackingRefreshAndStack.new()
status_data.stacking_policy = policy
status_data.max_stacks = 5
```

### 4. 累计持续时间（Accumulate Duration）

新状态增加持续时间，不叠加层数。

**适用场景：** 持续时间可累计的状态

```gdscript
var policy = StackingAccumulateDuration.new()
status_data.stacking_policy = policy
status_data.max_stacks = 1
```

## 持续时间策略

### 1. 自然时间（Natural Time）

使用游戏的自然时间（不受游戏暂停影响）。

```gdscript
var policy = DurationNaturalTime.new()
status_data.duration_policy = policy
```

### 2. 游戏时间（Game Time）

使用游戏时间（受游戏暂停影响）。

```gdscript
var policy = DurationGameTime.new()
status_data.duration_policy = policy
```

## 创建状态

### 步骤 1: 创建状态数据

1. 创建 `GameplayStatusData` 资源
2. 配置基本属性：
   ```gdscript
   var burn_status = GameplayStatusData.new()
   burn_status.status_id = &"burn"
   burn_status.status_display_name = "燃烧"
   burn_status.duration = 10.0  # 持续 10 秒
   burn_status.max_stacks = 1
   ```

### 步骤 2: 配置叠加策略

```gdscript
var stacking_policy = StackingRefreshDuration.new()
burn_status.stacking_policy = stacking_policy
```

### 步骤 3: 添加应用效果

```gdscript
# 创建伤害效果
var damage_effect = GEApplyDamage.new()
damage_effect.damage_amount = 10.0

# 添加到应用效果列表
burn_status.apply_effects.append(damage_effect)
```

### 步骤 4: 添加状态特性（可选）

```gdscript
# 添加周期性效果特性
var periodic_feature = FeaturePeriodicEffects.new()
periodic_feature.interval = 1.0  # 每秒触发一次
periodic_feature.effects = [damage_effect]
burn_status.features.append(periodic_feature)
```

## 使用状态

### 应用状态

```gdscript
@onready var status_component: GameplayStatusComponent = $GameplayStatusComponent

# 应用状态
status_component.apply_status(burn_status_data)

# 应用状态并指定来源
status_component.apply_status(burn_status_data, "fire_ability")
```

### 移除状态

```gdscript
# 移除状态（通过ID）
status_component.remove_status(&"burn")

# 移除状态（通过数据）
status_component.remove_status_by_data(burn_status_data)

# 移除所有状态
status_component.remove_all_statuses()

# 移除特定标签的状态
status_component.remove_statuses_by_tag(&"debuff")
```

### 查询状态

```gdscript
# 检查是否有状态
if status_component.has_status(&"burn"):
    print("角色正在燃烧")

# 获取状态实例
var burn_instance = status_component.get_status(&"burn")
if burn_instance:
    print("燃烧层数: ", burn_instance.stacks)
    print("剩余时间: ", burn_instance.get_remaining_time())

# 获取所有状态
var all_statuses = status_component.get_all_statuses()

# 获取特定标签的状态
var debuffs = status_component.get_statuses_by_tag(&"debuff")
```

## 状态特性（Features）

状态特性用于实现复杂的状态行为。

### 1. 周期性效果（Periodic Effects）

定期触发效果。

```gdscript
var periodic_feature = FeaturePeriodicEffects.new()
periodic_feature.interval = 2.0  # 每 2 秒触发一次
periodic_feature.effects = [damage_effect]
status_data.features.append(periodic_feature)
```

### 2. 事件监听（Event Listener）

监听游戏事件并响应。

```gdscript
var event_feature = FeatureEventListener.new()
event_feature.event_name = &"on_take_damage"
event_feature.effects = [counter_attack_effect]
status_data.features.append(event_feature)
```

## 状态效果

状态可以包含多种效果：

### 应用时效果（Apply Effects）

状态应用时触发的一次性效果。

```gdscript
# 初始伤害
var initial_damage = GEApplyDamage.new()
initial_damage.damage_amount = 50.0

# 属性修改
var attribute_modifier = GEAttributeModifier.new()
attribute_modifier.attribute_id = &"attack"
attribute_modifier.modifier_type = GameplayAttributeModifier.ModifierType.ADD
attribute_modifier.value = 20.0

status_data.apply_effects = [initial_damage, attribute_modifier]
```

### 移除时效果（Remove Effects）

状态移除时触发的效果。

```gdscript
# 移除属性修改
var remove_modifier = GEAttributeModifier.new()
remove_modifier.attribute_id = &"attack"
remove_modifier.modifier_type = GameplayAttributeModifier.ModifierType.ADD
remove_modifier.value = -20.0  # 移除时减去

status_data.remove_effects = [remove_modifier]
```

## 状态信号

状态组件提供信号用于响应状态变化：

```gdscript
# 连接信号
status_component.status_applied.connect(_on_status_applied)
status_component.status_removed.connect(_on_status_removed)
status_component.status_stacks_changed.connect(_on_status_stacks_changed)

func _on_status_applied(status_instance: GameplayStatusInstance) -> void:
    print("状态应用: ", status_instance.get_data().status_display_name)

func _on_status_removed(status_id: StringName) -> void:
    print("状态移除: ", status_id)

func _on_status_stacks_changed(status_instance: GameplayStatusInstance, old_stacks: int, new_stacks: int) -> void:
    print("层数变化: ", old_stacks, " -> ", new_stacks)
```

## 状态优先级

状态可以设置优先级，优先级高的状态可以替换优先级低的状态。

```gdscript
# 设置状态优先级
status_data.priority = 10  # 数字越大优先级越高

# 应用状态时，如果已有相同或更高优先级的状态，可能会被替换
```

## 状态免疫

通过标签系统实现状态免疫：

```gdscript
# 检查状态免疫
if status_component.is_immune_to(&"burn"):
    return  # 免疫燃烧状态

# 添加免疫标签
status_component.add_immunity_tag(&"burn")
```

## 状态与技能系统集成

技能可以通过效果系统应用状态：

```gdscript
# 在技能效果中应用状态
var apply_status_effect = GEApplyStatus.new()
apply_status_effect.status_data = burn_status_data
apply_status_effect.duration = 10.0

# 添加到技能效果列表
ability_definition.effects.append(apply_status_effect)
```

## 最佳实践

1. **合理使用叠加策略**：根据游戏需求选择合适的叠加策略
2. **使用状态特性**：通过特性实现复杂的状态行为
3. **及时清理状态**：状态移除时确保清理所有相关效果
4. **使用信号更新UI**：状态变化时通过信号通知UI更新
5. **利用状态优先级**：通过优先级控制状态的替换逻辑

## 总结

状态系统提供了完整的 Buff/Debuff 管理框架，支持状态的叠加、持续时间、效果应用等功能。通过灵活的策略系统，可以满足各种游戏需求。

