import numpy as np
import subprocess
import time
import sys
import signal

HYBRID_SINK = "hybrid_voice_input"
A50_SOURCE = "alsa_input.usb-Logitech_A50-00.pro-input-0"
SCARLETT_SOURCE = "alsa_input.usb-Focusrite_Scarlett_2i2_4th_Gen_S20KXTT350BDD8-00.pro-input-0"

SILENCE_THRESHOLD = 0.0001
SILENCE_DURATION = 0.5
CHECK_INTERVAL = 0.1


class AudioMonitor:
    def __init__(self):
        self.current_source = None
        self.last_link_time = 0
        # Initialize as if no voice has been heard for a long time.
        self.last_voice_time = time.time() - SILENCE_DURATION - 1.0
        self.running = True

    def link_source(self, source, sink):
        try:
            other_source = SCARLETT_SOURCE if source == A50_SOURCE else A50_SOURCE

            # Disconnect the other source if it's connected
            subprocess.run(
                ["pw-link", "--disconnect", other_source, sink],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )

            result = subprocess.run(["pw-link", source, sink], capture_output=True, text=True)
            if result.returncode != 0 and "File exists" not in result.stderr:
                print(f"Error linking source: {result.stderr}", flush=True)

        except subprocess.CalledProcessError as e:
            print(f"Error linking source: {e}", flush=True)

    def set_active_source(self, source_name):
        now = time.time()
        is_new_source = self.current_source != source_name

        if not is_new_source and (now - self.last_link_time < 3.0):
            return

        if is_new_source:
            self.current_source = source_name

        self.link_source(source_name, HYBRID_SINK)
        self.last_link_time = now

    def run(self):
        print("Starting Audio Auto-Switch Monitor...", flush=True)
        print(f"Targeting Source: {A50_SOURCE}", flush=True)

        self.set_active_source(A50_SOURCE)

        samplerate = 48000
        channels = 1
        format_str = 'float32le'
        bytes_per_sample = 4
        block_size = int(samplerate * CHECK_INTERVAL * channels * bytes_per_sample)

        cmd = [
            "parec",
            f"--device={A50_SOURCE}",
            f"--rate={samplerate}",
            f"--channels={channels}",
            f"--format={format_str}",
            "--latency-msec=100",
            "--client-name=Audio Monitor",
            "--stream-name=Audio Monitor"
        ]

        print(f"Running capture command: {' '.join(cmd)}", flush=True)

        process = None
        try:
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=sys.stderr)
            print("Capture process started.", flush=True)

            while self.running:
                raw_data = process.stdout.read(block_size)
                if not raw_data:
                    print("No data received from parecord. Exiting.", flush=True)
                    break

                indata = np.frombuffer(raw_data, dtype=np.float32)
                rms = np.sqrt(np.mean(indata**2))

                if rms > SILENCE_THRESHOLD:
                    self.last_voice_time = time.time()

                time_since_voice = time.time() - self.last_voice_time
                if time_since_voice < SILENCE_DURATION:
                    self.set_active_source(A50_SOURCE)
                else:
                    self.set_active_source(SCARLETT_SOURCE)

        except Exception as e:
            print(f"Fatal error: {e}", flush=True)
        finally:
            if process:
                process.terminate()


def main():
    monitor = AudioMonitor()

    def signal_handler(sig, frame):
        monitor.running = False

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    monitor.run()


if __name__ == "__main__":
    main()
