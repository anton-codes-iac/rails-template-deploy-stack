say "\n☁️  [deploy-stack] Scaffolding AWS Fargate & RDS infrastructure for Rails...", :green

# --- 1. COLLECT ALL INPUTS ---
say "\nWhich AWS region do you want to deploy to?", :cyan
say "1) us-east-1 (N. Virginia)"
say "2) us-east-2 (Ohio)"
say "3) eu-west-1 (Ireland)"
say "4) eu-central-1 (Frankfurt)"
say "5) ap-southeast-2 (Sydney)"
region_choice = ask("Enter the number of your choice (1-5):", limited_to: ["1", "2", "3", "4", "5"], default: "1")
regions = { "1" => "us-east-1", "2" => "us-east-2", "3" => "eu-west-1", "4" => "eu-central-1", "5" => "ap-southeast-2" }
aws_region = regions[region_choice]

needs_db = yes?("\nDo you need a managed AWS RDS PostgreSQL database? (y/n)")
db_flag = needs_db ? "true" : "false"

port_input = ask("\nWhat port does your Rails application listen on? (default: 3000)")
port = port_input.strip.empty? ? "3000" : port_input.strip

# --- 2. PREPARE DEPENDENCIES & PATCH CVEs ---
if needs_db
  say "\n🐘 Injecting PostgreSQL dependencies...", :blue
  gem "pg"
  gsub_file "config/database.yml", /adapter: sqlite3/, "adapter: postgresql", verbose: false
end

say "⚙️  Configuring AWS ALB health check route...", :blue
route 'root "rails/health#show"'

say "🛡️  Patching default Ruby library CVEs...", :blue
gem "erb", ">= 4.0.4"
gem "net-imap", ">= 0.4.24"
gem "resolv", ">= 0.3.2"
gem "rexml", ">= 3.3.9"
gem "uri", ">= 0.13.3"
gem "zlib", ">= 3.1.2"

# --- 3. EXECUTE AT THE VERY END ---
after_bundle do
  say "\n🛠️  Adding Alpine Linux (musl) platforms to Gemfile.lock...", :blue
  run "bundle lock --add-platform=x86_64-linux-musl > /dev/null 2>&1"
  run "bundle lock --add-platform=aarch64-linux-musl > /dev/null 2>&1"

  say "🤖 Running deploy-stack in headless mode...\n", :blue
  run "npx --yes deploy-stack@latest --headless --framework=rails --region=#{aws_region} --needsDatabase=#{db_flag} --port=#{port}"
end