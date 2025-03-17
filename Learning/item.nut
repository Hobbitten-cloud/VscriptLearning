// -----------------------
// Script by Pasas1345 
// -----------------------

// --------------------------------------------------------
// The base of all items. Attach this script to a movelinear
// attached to a pistol. Any other scripts will be attached to
// either the model or a seperate entity.
//
// Call SetEntity() to set the necessary entities.
// Call SetScript() and set the script scope of an item
// 					there.
// --------------------------------------------------------

item_script <- null

button <- null
button_set <- false
pistol <- self.GetMoveParent()
item_holder <- null

ticking <- false

function SetEntity(index) {
	switch(index) {
		case 0: {
			button = caller
			break
		}
	}
}

function SetScript(entity) {
	item_script = entity.GetScriptScope()
}

// Player used it
function Use(activator) {
	if (activator == item_holder)
		item_script.Use(activator)
}

function ItemPickUp() {
	item_holder = activator

	// When this item gets picked up, set up the button to handle Use.
	// Items can override the button setting, in case they have their own use function, like detecting +use presses instead of a button.
	// Ex: Elemental Staff Items
	if (!button_set) {
		button.ValidateScriptScope()
		button.GetScriptScope().item_script <- self.GetScriptScope()
		button.GetScriptScope().InputUse <- function() {
			return self.GetRootMoveParent() == activator
		}
		button.GetScriptScope().Use <- function() {
			item_script.Use(activator)
		}

		button.ConnectOutput("OnPressed", "Use")

		button_set = true
	}

	if ("ItemPickUp" in item_script)
		item_script.ItemPickUp(activator)

	ticking = true
	Tick()
}

// Called when player drops item
function ItemDrop() {
	// Clear any Think Functions that items added to the item holder. If they do exist of course.
	AddThinkToEnt(item_holder, null)

	// Handle removing the Think function if item script adds a Think function to the player.
	if ("ItemHolderThink" in item_holder.GetScriptScope())
		delete item_holder.GetScriptScope().ItemHolderThink

	// Call ItemDrop if item script has it as well.
	if ("ItemDrop" in item_script) 
		item_script.ItemDrop(item_holder)

	item_holder = null
	ticking = false
}

function Tick() {
	if (!ticking)
		return

	// Check if the player drops the item, or dies.
	if (!self.GetRootMoveParent() || !item_holder.IsAlive()) {
		ItemDrop()
		return
	}

	// If the item script has a Tick function, call it as well.
	if ("Tick" in item_script)
		item_script.Tick()

	// Loop
	EntFireByHandle(self, "RunScriptCode", "Tick()", 0.05, null, null)
}
