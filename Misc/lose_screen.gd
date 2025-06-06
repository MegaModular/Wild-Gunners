extends Node2D

func _ready():
	
	$Label.set_text("You lose! \nYou made it to round " + str(Globals.roundCount) + "\nAs punishment, you must restart the game yourself.")
