extends Line2D

const MAX_POINTS := 10000
var point = Vector2()
var points_list = [] # List for delaying the collision shape
const COLL_DELAY : int = 20
#@onready var collision_polygon = $StaticBody2D/CollisionShape2D
var collisionTrailScene: PackedScene = preload("res://src/trail/collisionTrailScene.tscn")

func _ready():
	# Clear default points
	clear_points()
	
func _process(_delta) -> void:
	point = get_parent().global_position
	add_point(point)
	points_list.append(point)
	
	if points_list.size() >= COLL_DELAY :
		var collision = collisionTrailScene.instantiate()
		collision.global_position = points_list[-COLL_DELAY]
		add_child(collision)
		collision.add_to_group("Trails")
		
		var collision_shape = collision.get_node("CollisionShape2D")
		collision_shape.shape.radius = width/4
	
	## Créer un nouveau CollisionShape2D
	#var rigid_body = RigidBody2D.new()
	#var collision_shape = CollisionShape2D.new()
	#rigid_body.global_position = point
	#collision_shape.global_position = point
		#
	## Créer une forme de collision (par exemple, un CircleShape2D)
	#var shape = CircleShape2D.new()
	#shape.radius = width/2  # Définir le rayon du cercle
#
	## Assigner la forme de collision au CollisionShape2D
	#collision_shape.shape = shape
#
	## Ajouter le CollisionShape2D au nœud racine
	#add_child(rigid_body)
	#rigid_body.add_child(collision_shape)
	
