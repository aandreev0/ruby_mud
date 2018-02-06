def save_players(*args)
  Player.save_all
  send_to_all("База игроков сохранена.")
end

def reboot_server(*args)
  @@log.info "---=== REBOOTING ===---"
  send_to_all "---=== REBOOTING ===---"
  save_players
  @@server.stop
end