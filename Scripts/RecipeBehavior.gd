class_name Recipe

extends Node

@export var dev_units: int
#@export var design_units: int
#@export var engineering_units: int
#@export var marketing_units: int
@export var in_units: Array[Node]
@export var out_units: Array[Node]

@onready var dev_progress: int = dev_units
