all:
	@ruby -c keep_alive/ping.rb
	@ruby -c new_game/multi_play.rb
	@ruby -c new_game/multiplex_manager.rb
	@ruby -c reaper/cleanup.rb
	sls deploy
