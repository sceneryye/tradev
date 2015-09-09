
 class Ecstore::ExpressRule < Ecstore::Base
   	self.table_name ="sdb_b2c_express_rules"
  	self.accessible_all_columns



   # def self.serachall (departure,arrival)
   #   sql="select * from sdb_b2c_expresses where departure=? and arrival=?",departure,arrival;
   #   Ecstore::Express.find_by_sql(sql);
   # end

end
