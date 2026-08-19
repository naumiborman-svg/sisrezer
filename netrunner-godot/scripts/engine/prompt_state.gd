class_name NRPromptState
extends RefCounted
## Prompt queue. Port of game.core.prompt_state.

static func set_prompt_state(state: NRState, side: String, prompt: Variant = "__current__") -> void:
	var s := NRUtil.to_side(side)
	if str(prompt) == "__current__":
		var prompts: Array = state.get_in([s, "prompt"], [])
		prompt = prompts[0] if not prompts.is_empty() else null
	state.assoc_in([s, "prompt-state"], prompt)


static func remove_from_prompt_queue(state: NRState, side: String, prompt: Dictionary) -> void:
	var s := NRUtil.to_side(side)
	var prompts: Array = state.get_in([s, "prompt"], [])
	var out: Array = []
	for p in prompts:
		if p != prompt:
			out.append(p)
	state.assoc_in([s, "prompt"], out)
	set_prompt_state(state, s)


static func add_to_prompt_queue(state: NRState, side: String, prompt: Dictionary) -> void:
	var s := NRUtil.to_side(side)
	var prompts: Array = state.get_in([s, "prompt"], [])
	prompts = [prompt] + prompts
	state.assoc_in([s, "prompt"], prompts)
	set_prompt_state(state, s)
