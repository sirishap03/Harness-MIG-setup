provider "google"  {              #mentioning the provider
     project_id = " "
     region     = "us-east-1"
     zone       = "  "
}

resource "google_cloud_instance_template" "default"  {     # creation of template for MIG setup
     name_prefix   = mig-server
     instance_type = e2.medium
     
     tags = [apache_server]

     disk {
       source_image = "debian-cloud/debian-11"          #source image debain 11 from debian cloud which is  a public image
       delete       = true                              #whenever the vm deletes, disk should also deleted
       boot         = true                              #re-boot  whenever the application requires
     }

     network_interface {
       network       = "default"                       #taking up default vpc
       access_config {}                                # enable the public access for ip
     } 
     

      metadata_startup_script = <<-EOT                  #metadata for installing apache on the multiple instances
           sudo apt update
           sudo apt install -y apache2
           sudo systemctl enable apache2
           sudo systemctl start apache2
           EOT
      }
     
