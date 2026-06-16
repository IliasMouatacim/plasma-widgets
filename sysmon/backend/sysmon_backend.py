import json
import time
import psutil
import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
import threading

class SystemMonitor:
    def __init__(self):
        self.last_net_io = psutil.net_io_counters()
        self.last_time = time.time()
        self.cpu_percent = 0.0
        self.ram_percent = 0.0
        self.net_up_speed = 0.0
        self.net_down_speed = 0.0
        self.gpu_temp = "N/A"
        
        self.running = True
        self.thread = threading.Thread(target=self.update_loop)
        self.thread.daemon = True
        self.thread.start()

    def update_loop(self):
        # Initial call to cpu_percent to set the baseline
        psutil.cpu_percent(interval=None)
        time.sleep(0.5)
        
        while self.running:
            try:
                self.cpu_percent = psutil.cpu_percent(interval=None)
                self.ram_percent = psutil.virtual_memory().percent
                
                # Network speeds
                current_time = time.time()
                current_net_io = psutil.net_io_counters()
                
                time_diff = current_time - self.last_time
                if time_diff > 0:
                    bytes_sent = current_net_io.bytes_sent - self.last_net_io.bytes_sent
                    bytes_recv = current_net_io.bytes_recv - self.last_net_io.bytes_recv
                    
                    self.net_up_speed = (bytes_sent / time_diff) / 1024 # KB/s
                    self.net_down_speed = (bytes_recv / time_diff) / 1024 # KB/s
                
                self.last_net_io = current_net_io
                self.last_time = current_time
                
                # GPU Temp
                try:
                    result = subprocess.check_output(
                        ['nvidia-smi', '--query-gpu=temperature.gpu', '--format=csv,noheader'], 
                        stderr=subprocess.DEVNULL
                    )
                    self.gpu_temp = result.decode('utf-8').strip()
                except Exception:
                    self.gpu_temp = "N/A"
                    
            except Exception as e:
                pass
            
            time.sleep(1)

    def get_stats(self):
        return {
            "cpu": self.cpu_percent,
            "ram": self.ram_percent,
            "net_up": round(self.net_up_speed, 1),
            "net_down": round(self.net_down_speed, 1),
            "gpu_temp": self.gpu_temp
        }

monitor = SystemMonitor()

class RequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path == "/stats":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(monitor.get_stats()).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    server_address = ('127.0.0.1', 8082)
    httpd = HTTPServer(server_address, RequestHandler)
    httpd.serve_forever()
