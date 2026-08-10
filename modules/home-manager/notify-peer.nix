{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "notify-peer";
      runtimeInputs = [ pkgs.jq ];
      text = ''
        peer="''${1:-}"
        message="''${2:-}"

        if [ -z "$peer" ] || [ -z "$message" ]; then
          echo "usage: notify-peer <peer-session-name> <message>" >&2
          exit 1
        fi

        agents=$(claude agents --json)

        count=$(jq --arg name "$peer" '[.[] | select(.name == $name)] | length' <<< "$agents")
        if [ "$count" -eq 0 ]; then
          echo "notify-peer: no running session named '$peer'" >&2
          exit 1
        fi
        if [ "$count" -gt 1 ]; then
          echo "notify-peer: multiple running sessions named '$peer' — rename one and retry" >&2
          exit 1
        fi
        cwd=$(jq -r --arg name "$peer" '.[] | select(.name == $name) | .cwd' <<< "$agents")

        sender=""
        p=$PPID
        while [ -n "$p" ] && [ "$p" -gt 1 ]; do
          sender=$(jq -r --argjson pid "$p" '.[] | select(.pid == $pid) | .name' <<< "$agents")
          [ -n "$sender" ] && break
          p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ' || true)
        done

        message=$(tr '\n\r' '  ' <<< "$message")
        if [ -n "$sender" ]; then
          message="[from $sender] $message [to reply, run the shell command: notify-peer $sender \"<your reply>\"]"
        fi

        result=$(osascript - "$peer" "$cwd" "$message" <<'APPLESCRIPT'
        on run argv
        	set peerName to item 1 of argv
        	set peerCwd to item 2 of argv
        	set msg to item 3 of argv

        	tell application "Ghostty"
        		set byName to {}
        		set byCwd to {}
        		repeat with w in windows
        			repeat with t in tabs of w
        				repeat with s in terminals of t
        					if (name of s) ends with peerName then set end of byName to s
        					if (working directory of s) is peerCwd then set end of byCwd to s
        				end repeat
        			end repeat
        		end repeat

        		if (count of byName) is 1 then
        			set target to item 1 of byName
        		else if (count of byName) > 1 then
        			return "ambiguous: " & (count of byName) & " surfaces are titled like '" & peerName & "'"
        		else if (count of byCwd) is 1 then
        			set target to item 1 of byCwd
        		else if (count of byCwd) > 1 then
        			return "ambiguous: no surface titled '" & peerName & "' and " & (count of byCwd) & " surfaces are in " & peerCwd & " — start the peer with: claude --name " & peerName
        		else
        			return "notfound"
        		end if

        		input text msg to target
        		delay 0.1
        		send key "enter" to target
        	end tell
        	return "ok"
        end run
        APPLESCRIPT
        )

        if [ "$result" = "notfound" ]; then
          echo "notify-peer: could not resolve a Ghostty surface for '$peer' (cwd $cwd)" >&2
          exit 1
        fi
        if [ "$result" != "ok" ]; then
          echo "notify-peer: $result" >&2
          exit 1
        fi
      '';
    })
  ];
}
