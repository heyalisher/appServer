from flask import Flask, request, jsonify
from transformers import T5ForConditionalGeneration, T5Tokenizer

app = Flask(__name__)

# Load T5 model and tokenizer from the model folder
model_path = "model/"
model = T5ForConditionalGeneration.from_pretrained(model_path)
tokenizer = T5Tokenizer.from_pretrained(model_path)

@app.route('/summarize', methods=['POST'])
def summarize():
    try:
        # Check if the request contains a file or text
        print('Request:', request.form, request.files)
        if 'file' in request.files:
            uploaded_file = request.files['file']
            if uploaded_file.filename != '':
                file_contents = uploaded_file.read().decode('utf-8')
                summary = generate_summary(file_contents)
                return jsonify({'summary': summary})
        elif 'text' in request.form:
            text = request.form['text']
            summary = generate_summary(text)
            return jsonify({'summary': summary})
        return jsonify({'error': 'No file or text provided'})
    except Exception as e:
        # Handle any exceptions and return an error message
        print(f"Error in summarization: {e}")
        return jsonify({'error': 'Failed to generate summary'})

def generate_summary(text):
    try:
        print("Input text:", text)  # Print the input text for debugging
        # Tokenize the input text using the tokenizer
        input_ids = tokenizer.encode(text, return_tensors="pt", max_length=512, truncation=True)

        # Generate the summary using the pre-trained model
        summary_ids = model.generate(input_ids, max_length=150, num_beams=4, early_stopping=True)

        # Decode the summary tokens back into text
        summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
        print("Generated summary:", summary)  # Print the generated summary for debugging
        return summary
    except Exception as e:
        # Handle any exceptions and return an error message
        print(f"Error in generating summary: {e}")
        return 'Error: Failed to generate summary'

if __name__ == '__main__':
    app.run(debug=True, port=9001)