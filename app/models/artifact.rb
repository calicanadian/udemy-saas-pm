class Artifact < ApplicationRecord
  attr_accessor :upload
  belongs_to :project

  MAX_FILESIZE = 10.megabytes
  validates_presence_of :name, :upload
  validates_uniqueness_of :name
  validate :uploaded_file_size

  before_save :upload_to_s3

  private

    def upload_to_s3
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      tenant_name = Tenant.find(Thread.current[:tenant_id]).id
      obj = s3.bucket(ENV['S3_BUCKET']).object("#{tenant_name}/#{upload.original_filename}")
      puts "OBJECT: #{obj.inspect}"
      puts "UPLOAD: #{upload.path}"
      obj.upload_file(upload.path, acl: "public-read")
      self.key = obj.public_url
    end

    def uploaded_file_size
      if upload
        errors.add(:upload, "File size must be less than #{self.class::MAX_FILESIZE}") unless upload.size <= self.class::MAX_FILESIZE
      end
    end
end
