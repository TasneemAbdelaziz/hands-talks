import whisper, requests, tempfile, os
from flask import Flask, request, jsonify

app = Flask(__name__)
model = whisper.load_model("base")         # "tiny", "small", … as you wish

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    audio_url = (request.json or {}).get('url')
    if not audio_url:
        return jsonify(error="Missing audio URL"), 400

    try:
        resp = requests.get(audio_url, timeout=30)
        if resp.status_code != 200:
            return jsonify(error="Unable to download audio"), 400

        # choose suffix from URL or default to .m4a
        suffix = os.path.splitext(audio_url.split("?")[0])[1] or ".m4a"

        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
            tmp.write(resp.content)
            tmp_path = tmp.name

        result = model.transcribe(tmp_path, language="ar")
        return jsonify(text=result["text"])
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        try:
            if 'tmp_path' in locals() and os.path.exists(tmp_path):
                os.remove(tmp_path)
        except Exception:
            pass      # silent cleanup failure

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
