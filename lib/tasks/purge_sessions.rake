task :clear_expired_sessions => :environment do
    sql = 'DELETE FROM sessions WHERE updated_at < DATE_SUB(NOW(), INTERVAL 2 WEEK);'
    ActiveRecord::Base.connection.execute(sql)
end