require 'dotenv'
require 'http'
require 'json'

Dotenv.load

def converse_with_ai(api_key, conversation_history)
  url = "https://api.openai.com/v1/chat/completions"
  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{api_key}"
  }

  conversation = conversation_history.dup  # Dupliquez l'historique pour éviter de le modifier directement

  loop do
    user_input = gets.chomp

    break if user_input.downcase == 'stop'

    conversation << { "role" => "user", "content" => user_input }

    data = {
      "model" => "gpt-3.5-turbo",
      "messages" => conversation,
      "max_tokens" => 500,
      "temperature" => 0.0  # Ajustez la température selon vos préférences
    }

    begin
      response = HTTP.headers(headers).post(url, json: data)
      puts response
      response_body = JSON.parse(response.body.to_s)
       
      if response.status.success?
        text = response_body['choices'][0]['message']['content'].strip
        puts "IA : #{text}"

        conversation << { "role" => "system", "content" => "You are a helpful assistant." }
        conversation << { "role" => "assistant", "content" => text }
      else
        puts "La requête vers l'API OpenAI a échoué avec le statut : #{response.status}"
      end
    rescue HTTP::Error => e
      puts "Erreur lors de la requête vers l'API OpenAI : #{e.message}"
      puts e.backtrace
    rescue JSON::ParserError => e
      puts "Erreur de parsing JSON : #{e.message}"
    end
  end
end

# Utilisation de la méthode converse_with_ai
api_key = ENV["OPENAI_API_KEY"]

if api_key.nil? || api_key.empty?
  puts "Erreur: La clé d'API OpenAI n'est pas définie. Veuillez vérifier votre configuration."
else
  puts "API Key: #{api_key}"
  puts "Vous :"

  # Initialisez l'historique de conversation avec le message système initial
  conversation_history = [
    { "role" => "system", "content" => "You are a helpful assistant." }
  ]

  converse_with_ai(api_key, conversation_history)
end
