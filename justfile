switch:
	@sudo switch
	@post-switch	

update-ai:
	./update_codex.sh
	./update_copilot.sh
	./update_opencode.sh
