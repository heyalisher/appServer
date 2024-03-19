from flask import Flask, request, jsonify, redirect, url_for, render_template, session
from transformers import T5ForConditionalGeneration, T5Tokenizer
from firebase_admin import auth
# import joblib
import firebase_admin
from firebase_admin import credentials

app = Flask(__name__)

# Load T5 model and tokenizer from the model folder
model_path = "model/"
model = T5ForConditionalGeneration.from_pretrained(model_path)
tokenizer = T5Tokenizer.from_pretrained(model_path)

# Initialize Firebase Admin SDK
cred = credentials.Certificate('static/firebase_credentials.json')
firebase_admin.initialize_app(cred)
app = Flask(__name__)

app.secret_key = '1:309701962526:web:8c62ec83d7ae833588b70f'
logg=True



@app.context_processor
def inject_user_auth():
    return dict(is_user_logged_in=logg)

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        print('Request:', request.form, request.files)
        if 'file' in request.files:
            uploaded_file = request.files['file']
            if uploaded_file.filename != '':
                file_contents = uploaded_file.read().decode('utf-8')
                summary = generate_summary(file_contents)
                if summary:
                    return jsonify({'summary': summary})
                else:
                    return jsonify({'error': 'Failed to generate summary'})

        elif 'text' in request.form:
            text = request.form['text']
            summary = generate_summary(text)
            if summary:
                return jsonify({'summary': summary})
            else:
                return jsonify({'error': 'Failed to generate summary'})

    return render_template('fyp2.html')

def generate_summary(text):
    try:
        input_ids = tokenizer.encode(text, return_tensors="pt", max_length=512, truncation=True)
        summary_ids = model.generate(input_ids, max_length=150, num_beams=4, early_stopping=True)
        summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
        return summary
    except Exception as e:
        print(f"Error in generating summary: {e}")
        return None

@app.route('/authpage', methods=['GET'])
def aut_page():
    return render_template('index.html')


@app.route('/signup', methods=['POST'])
def signup():
    global logg
    email = request.form['email']
    password = request.form['password']

    try:
        user = auth.create_user(
            email=email,
            password=password
        )
        logg=True

        return redirect(url_for('home'))
    except Exception as e:
        return jsonify({'error': str(e)})


@app.route('/login', methods=['POST'])
def login():
    global logg
    email = request.form['email']
    password = request.form['password']
    try:
        user = auth.get_user_by_email(email)
        print(user)
        logg=True
        # TODO: Implement password verification
        return redirect(url_for('home'))
    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/logout')
def logout():
    global logg
    print(session)
    session.pop('user', None)
    logg=False
    print("Logout ho gaya")
    return redirect(url_for('home'))



if __name__ == '__main__':
    app.run(debug=True)