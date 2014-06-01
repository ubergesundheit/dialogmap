desc "Upgrade the database user to superuser"
task :dbuser_to_superuser do
  on roles(:all) do
    sudo :su, '-l -c "psql -c \'ALTER ROLE dialog_map WITH SUPERUSER;\'" - postgres'
  end
end

desc "Take superuser away from database user"
task :dbuser_from_superuser do
  on roles(:all) do
    sudo :su, '-l -c "psql -c \'ALTER ROLE dialog_map WITH NOSUPERUSER;\'" - postgres'
  end
end
