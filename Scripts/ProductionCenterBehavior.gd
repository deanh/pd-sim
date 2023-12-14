class_name ProductionCenter
extends Node

@export var recipe: Node
@export var design_capacity: int
@export var engineering_capacity: int
@export var marketing_capacity: int
@export var backlog: Array[Recipe]
@export_enum("Ready", "Working", "Waiting") var status: String

@export var current_recipe: Recipe

var finished_recipes: Array[Recipe] = []
var inventory: Array[Node]

func daily_work() -> void:
    var can_work: bool = true
    # make sure we have work assigned
    if !current_recipe:
        # check backlog for work
        if backlog.size() > 0:
            current_recipe = backlog.pop_front()
        else:
            Messenger.emit_signal("waiting_for_backlog")
            status = "Ready"
            return
    
    # make sure we have the inventory required for the work        
    for item in current_recipe.in_units:
        if !inventory.has(item):
            can_work = false
            status = "Waiting"
            Messenger.emit_signal("waiting_on_inventory", item.name)

    if can_work:
        status = "Working"
        apply_capacity_to_recipe(current_recipe)

func apply_capacity_to_recipe(recipe: Recipe) -> void:
    recipe.dev_progress -= basic_dev_capacity()
    if recipe.dev_progress <= 0:
        finish_recipe(recipe)

func finish_recipe(recipe: Recipe) -> void:
    # remove the inventory that the recipe uses
    for item in recipe.in_units:
        inventory.erase(item)
    # add inventory that the recipe produces
    for item in recipe.out_units:
        inventory.append(item)
        Messenger.emit_signal("unit_produced", item.name)
    Messenger.emit_signal("work_complete", recipe.name)
    finished_recipes.append(recipe)
    status = "Ready"
    current_recipe = backlog.pop_front()

# for now just make a basic capacity, but i would like this
# to be more granular to produce fitness for use, purpose,
# and change
func basic_dev_capacity() -> int:
    return engineering_capacity + design_capacity * 0.6
