namespace :deployment do
  desc 'Deploy the production environment'
  task :production do
    puts 'Deploy the production environment'
    Pipeline::Deploy.new environment: 'production'
  end
end
