require 'dotenv'
require 'http'
require 'json'

Dotenv.load

api_key = ENV["OPENAI_API_KEY"]
url = "https://api.openai.com/v1/chat/completions"

if api_key.nil? || api_key.empty?
  puts "Erreur: La clé d'API OpenAI n'est pas définie. Veuillez vérifier votre configuration."
else
  puts "API Key: #{api_key}"

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{api_key}"
  }

  # Ensure the prompt is formatted in a JSON-safe way
  prompt = '{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "Donnes moi 1 recette de cuisine aléatoire :"}'

  data = {
    "model" => "gpt-3.5-turbo",
    "messages" => [
      {"role" => "system", "content" => "You are a helpful assistant."},
      {"role" => "user", "content" => "Donnes moi 1 recette de cuisine aléatoire :"}
    ],
    "max_tokens" => 150,         # Ajout du paramètre max_tokens
    "temperature" => 0.2        # Ajout du paramètre temperature
  }
  

  begin
    response = HTTP.headers(headers).post(url, json: data)
    response_body = JSON.parse(response.body.to_s)

    puts "Réponse de l'API :"
    puts response_body.inspect

    if response.status.success?
      if response_body && response_body['error']
        puts "Erreur dans la réponse de l'API : #{response_body['error']['message']}"
      else
        text = response_body['choices'][0]['message']['content'].strip
        puts "Hello, voici 1 recette de cuisine aléatoire :"
        puts text
      end
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
