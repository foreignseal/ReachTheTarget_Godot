extends Area2D

@export var message: Label

func _on_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		message.text = "TARGET REACHED!"
