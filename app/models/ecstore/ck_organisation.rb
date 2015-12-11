#encoding:utf-8
class Ecstore::WeihuoOrganisation < Ecstore::Base
  self.table_name  = 'ck_organisations'
  self.accessible_all_columns

  has_many :ck_employees,:foreign_key=>"ck_organisation_id"
  has_many :ck_shops,:foreign_key=>"ck_organisation_id"

end