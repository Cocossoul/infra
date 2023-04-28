from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def bete():
    photo = b''
    with open("bete.png", 'rb') as f:
        photo = f.read()
    resp = app.make_response(photo)
    resp.mimetype = "image/png"
    return resp

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=False, port=8080)
