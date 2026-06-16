import dbus
import json
from http.server import BaseHTTPRequestHandler, HTTPServer

def get_deezer_player():
    try:
        bus = dbus.SessionBus()
        players = []
        for service in bus.list_names():
            if service.startswith('org.mpris.MediaPlayer2.'):
                if 'deezer' in service.lower():
                    return bus.get_object(service, '/org/mpris/MediaPlayer2')
                players.append(service)
        if players:
            return bus.get_object(players[0], '/org/mpris/MediaPlayer2')
    except Exception as e:
        print(f"DBus error: {e}")
    return None

def get_status():
    player = get_deezer_player()
    if not player:
        return {"status": "Offline"}
    
    try:
        props = dbus.Interface(player, 'org.freedesktop.DBus.Properties')
        playback_status = str(props.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus'))
        metadata = props.Get('org.mpris.MediaPlayer2.Player', 'Metadata')
        
        title = str(metadata.get('xesam:title', 'Unknown Track'))
        
        # Artist is an array of strings
        artist_raw = metadata.get('xesam:artist', ['Unknown Artist'])
        if isinstance(artist_raw, dbus.Array):
            artist = ', '.join([str(a) for a in artist_raw])
        else:
            artist = str(artist_raw)
            
        art_url = str(metadata.get('mpris:artUrl', ''))
        
        return {
            "status": playback_status,
            "title": title,
            "artist": artist,
            "artUrl": art_url
        }
    except Exception as e:
        return {"status": "Error", "message": str(e)}

def send_command(command):
    player = get_deezer_player()
    if not player: return
    try:
        interface = dbus.Interface(player, 'org.mpris.MediaPlayer2.Player')
        if command == "playpause":
            interface.PlayPause()
        elif command == "next":
            interface.Next()
        elif command == "previous":
            interface.Previous()
    except Exception as e:
        print(f"Failed to send command: {e}")

class RequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass # Disable logging to stdout to keep it clean

    def do_GET(self):
        if self.path == "/status":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(get_status()).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == "/playpause":
            send_command("playpause")
            self.send_response(200)
        elif self.path == "/next":
            send_command("next")
            self.send_response(200)
        elif self.path == "/previous":
            send_command("previous")
            self.send_response(200)
        else:
            self.send_response(404)
            
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()

if __name__ == '__main__':
    server_address = ('127.0.0.1', 8081)
    httpd = HTTPServer(server_address, RequestHandler)
    httpd.serve_forever()
