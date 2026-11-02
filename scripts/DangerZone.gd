extends Area2D

signal player_entered(player: Node2D)
@export var message: Label


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered.emit(body)
		message.text = "YOU CAN'T TOUCH THAT!"
		body.respawn()
