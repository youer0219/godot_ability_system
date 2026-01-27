# 行为树指南

## 概述

行为树（Behavior Tree）用于描述技能的执行逻辑，通过节点组合实现复杂的技能行为。

## 核心概念

### 行为树节点（BTNode）

所有行为树节点都继承自 `BTNode`，节点有三种执行结果：

- **SUCCESS**: 执行成功
- **FAILURE**: 执行失败
- **RUNNING**: 正在执行（需要持续更新）

### 黑板（Blackboard）

黑板用于在行为树节点之间传递数据。

**常用数据：**
- `ability_instance`: 技能实例
- `context`: 上下文数据
- `target`: 目标
- `damage`: 伤害数值
- `position`: 位置
- `direction`: 方向

## 节点类型

### 组合节点（Composites）

组合节点用于控制子节点的执行顺序。

#### 1. 顺序节点（BTSequence）

按顺序执行子节点，所有子节点成功才返回成功。

```
Sequence
├── Node1 (SUCCESS)
├── Node2 (SUCCESS)
└── Node3 (SUCCESS)
→ SUCCESS
```

**使用场景：** 需要按顺序执行多个步骤的技能

#### 2. 选择节点（BTSelector）

按顺序执行子节点，有一个子节点成功就返回成功。

```
Selector
├── Node1 (FAILURE)
├── Node2 (SUCCESS)
└── Node3 (未执行)
→ SUCCESS
```

**使用场景：** 尝试多种策略，直到成功

#### 3. 并行节点（BTParallel）

并行执行所有子节点。

```
Parallel
├── Node1 (RUNNING)
├── Node2 (SUCCESS)
└── Node3 (RUNNING)
→ RUNNING
```

**使用场景：** 同时执行多个独立操作

#### 4. 切换节点（BTSwitch）

根据条件切换到不同的子节点。

```
Switch
├── Case1: condition1 → Node1
├── Case2: condition2 → Node2
└── Default: Node3
```

**使用场景：** 根据条件执行不同的逻辑分支

### 装饰节点（Decorators）

装饰节点用于修改子节点的行为。

#### 1. 重复节点（BTRepeat）

重复执行子节点指定次数。

**属性：**
- `repeat_count`: 重复次数（-1 为无限）

**使用场景：** 重复执行某个操作

#### 2. 周期性重复（BTRepeatPeriodic）

周期性重复执行子节点。

**属性：**
- `interval`: 间隔时间（秒）

**使用场景：** 定期执行某个操作

#### 3. 直到失败（BTRepeatUntilFailure）

重复执行直到子节点失败。

**使用场景：** 持续执行直到条件不满足

#### 4. 条件节点（BTCondition）

检查条件，条件满足才执行子节点。

**属性：**
- `condition_key`: 黑板中的条件键
- `expected_value`: 期望值

**使用场景：** 条件判断

### 动作节点（Actions）

动作节点执行具体的游戏逻辑。

#### 1. 应用消耗（BTApplyCost）

应用技能的资源消耗。

**使用场景：** 技能释放时消耗魔法值

#### 2. 提交消耗（BTCommitCost）

提交技能的资源消耗（在技能确认释放时）。

**使用场景：** 技能确认释放时扣除资源

#### 3. 提交冷却（BTCommitCooldown）

提交技能的冷却时间。

**使用场景：** 技能确认释放时开始冷却

#### 4. 播放动画（BTPlayAnimation）

播放动画。

**属性：**
- `animation_name`: 动画名称
- `animation_player_path`: 动画播放器路径

**使用场景：** 技能释放动画

#### 5. 面向目标（BTFaceTarget）

让角色面向目标。

**属性：**
- `target_key`: 黑板中的目标键

**使用场景：** 释放技能时面向目标

#### 6. 生成投射物（BTSpawnProjectile）

生成投射物。

**属性：**
- `projectile_data_key`: 黑板中的投射物数据键
- `spawn_position_key`: 生成位置键
- `direction_key`: 方向键

**使用场景：** 发射投射物技能

#### 7. 生成魔法场（BTSpawnMagicField）

生成魔法场。

**属性：**
- `magic_field_data_key`: 魔法场数据键
- `spawn_position_key`: 生成位置键

**使用场景：** 生成持续伤害区域

#### 8. 应用效果（BTApplyEffect）

应用游戏效果。

**属性：**
- `effect_key`: 效果键
- `target_key`: 目标键

**使用场景：** 对目标应用伤害或治疗

#### 9. 移除状态（BTRemoveStatus）

移除目标的状态。

**属性：**
- `status_id_key`: 状态ID键
- `target_key`: 目标键

**使用场景：** 移除特定状态

#### 10. 等待信号（BTWaitSignal）

等待信号触发。

**属性：**
- `signal_name`: 信号名称
- `timeout`: 超时时间（-1 为无限等待）

**使用场景：** 等待动画完成、等待输入等

#### 11. 等待时间（BTWait）

等待指定时间。

**属性：**
- `wait_time`: 等待时间（秒）

**使用场景：** 延迟执行

## 创建行为树

### 步骤 1: 创建行为树资源

1. 在资源面板右键 -> `新建资源`
2. 选择 `BTNode`
3. 创建根节点（通常是 Sequence 或 Selector）

### 步骤 2: 构建行为树结构

在编辑器中构建行为树：

```
Sequence (根节点)
├── ApplyCost (应用消耗)
├── PlayAnimation (播放动画)
├── WaitSignal (等待动画完成)
├── SpawnProjectile (生成投射物)
└── CommitCooldown (提交冷却)
```

### 步骤 3: 配置节点参数

为每个节点配置参数：

```gdscript
# 播放动画节点
play_animation_node.animation_name = &"cast_fireball"
play_animation_node.animation_player_path = NodePath("AnimationPlayer")

# 生成投射物节点
spawn_projectile_node.projectile_data_key = "projectile_data"
spawn_projectile_node.spawn_position_key = "spawn_position"
spawn_projectile_node.direction_key = "direction"
```

### 步骤 4: 配置黑板数据

在技能定义中配置黑板默认数据：

```gdscript
ability_definition.blackboard_defaults = {
    "projectile_data": fireball_projectile_data,
    "spawn_position": Vector3(0, 1, 0),
    "direction": Vector3(1, 0, 0),
    "damage": 100.0
}
```

## 行为树示例

### 示例 1: 简单火球术

```
Sequence
├── ApplyCost (消耗魔法值)
├── PlayAnimation (播放施法动画)
├── WaitSignal (等待动画完成)
├── SpawnProjectile (生成火球)
└── CommitCooldown (开始冷却)
```

### 示例 2: 连击技能

```
Sequence
├── WaitSignal (等待输入信号)
├── Condition (检查连击计数)
│   └── PlayAnimation (播放连击动画)
├── WaitSignal (等待动画完成)
├── ApplyEffect (应用伤害)
└── UpdateComboCount (更新连击计数)
```

### 示例 3: 切换技能

```
Selector
├── Condition (检查是否已激活)
│   └── Sequence
│       ├── ApplyEffect (应用关闭效果)
│       └── SetActive (设置为未激活)
└── Sequence
    ├── ApplyCost (应用消耗)
    ├── ApplyEffect (应用开启效果)
    └── SetActive (设置为激活)
```

### 示例 4: 蓄力技能

```
Sequence
├── ApplyCost (应用消耗)
├── PlayAnimation (播放蓄力动画)
├── Parallel
│   ├── WaitSignal (等待释放信号)
│   └── RepeatPeriodic (周期性增加蓄力值)
├── CalculateCharge (计算蓄力倍率)
├── SpawnProjectile (生成投射物，使用蓄力倍率)
└── CommitCooldown (开始冷却)
```

## 黑板数据操作

### 读取黑板数据

```gdscript
# 在节点中读取
var damage = blackboard.get_var("damage", 0.0)
var target = blackboard.get_var("target", null)
```

### 设置黑板数据

```gdscript
# 在节点中设置
blackboard.set_var("damage", 150.0)
blackboard.set_var("target", new_target)
```

### 在技能中访问黑板

```gdscript
# 在技能实例中访问
var ability_instance = blackboard.get_var("ability_instance")
var damage = ability_instance.get_blackboard_var("damage", 0.0)
```

## 自定义节点

### 创建自定义节点

继承 `BTNode` 创建自定义节点：

```gdscript
extends BTNode
class_name CustomBTNode

@export var custom_parameter: float = 0.0

func execute(blackboard: BTBlackboard) -> BTNode.Result:
    # 读取黑板数据
    var target = blackboard.get_var("target", null)
    if not is_instance_valid(target):
        return BTNode.Result.FAILURE
    
    # 执行自定义逻辑
    target.custom_method(custom_parameter)
    
    return BTNode.Result.SUCCESS
```

## 最佳实践

1. **使用 Sequence 组织步骤**：按顺序执行的步骤使用 Sequence
2. **使用 Selector 处理分支**：条件分支使用 Selector
3. **合理使用并行节点**：独立操作使用 Parallel
4. **利用黑板传递数据**：节点间数据通过黑板传递
5. **使用条件节点控制流程**：条件判断使用 Condition 节点
6. **等待信号而非时间**：尽量使用 WaitSignal 而非 Wait

## 总结

行为树系统提供了灵活的技能逻辑描述方式，通过节点组合可以实现各种复杂的技能行为。合理使用行为树可以让技能逻辑更加清晰和易于维护。

