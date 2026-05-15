extends Resource
class_name SurvivorsEnemyResource

@export var enemy: PackedScene
@export_range(1, 9999, 1, "or_greater") var cost: int = 1
@export var spawn_distance_from_player: float = 150.0
@export var enemy_resource: EnemyResource
