# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV['BOX_NAME'] || "ubuntu"
BOX_URI = ENV['BOX_URI'] || "http://files.vagrantup.com/precise64.box"
VF_BOX_URI = ENV['BOX_URI'] || "http://files.vagrantup.com/precise64_vmware_fusion.box"
AWS_REGION = ENV['AWS_REGION'] || "us-east-1"
AWS_AMI    = ENV['AWS_AMI']    || "ami-d0f89fb9"
FORWARD_DOCKER_PORTS = ENV['FORWARD_DOCKER_PORTS']

Vagrant::Config.run do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI

  config.ssh.forward_agent = true

  config.vm.forward_port 80,1234
  config.vm.network :hostonly, "10.11.12.13"

  # Provision docker and new kernel if deployment was not done.
  # It is assumed Vagrant can successfully launch the provider instance.
  if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?
    # Add lxc-docker package
    pkg_cmd = "wget -q -O - https://get.docker.io/gpg | apt-key add -;" \
      "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list;" \
      "apt-get update -qq; apt-get install -q -y --force-yes lxc-docker; " \
      "apt-get install -y openjdk-7-jdk; " \
      "echo apt-get install openjdk-7-jdk; " \
      "wget https://github.com/downloads/jmxtrans/jmxtrans/jmxtrans_20121016-175251-ab6cfd36e3-1_all.deb; " \
      "echo wget https://github.com/downloads/jmxtrans/jmxtrans/jmxtrans_20121016-175251-ab6cfd36e3-1_all.deb; " \
      "export DEBIAN_FRONTEND=noninteractive; " \
      "dpkg -i jmxtrans_20121016-175251-ab6cfd36e3-1_all.deb; " \
      "echo dpkg -i jmxtrans_20121016-175251-ab6cfd36e3-1_all.deb; " \
      "sed -i '$ a\ export JMXTRANS_OPTS=\"-Dmyserverport=6789 -Dmyserverhost=12.13.14.15 -Dmygraphiteport=2003 -Dmygraphitehost=10.11.12.13\"'  /etc/default/jmxtrans; " \
      "sed -i s/60/15/g /etc/default/jmxtrans; " \
      "echo sed command to add JMXTRANX_OPTS alter time to get data; " \
      "cp /vagrant/jmxTransJsonFiles/* /var/lib/jmxtrans/. ;" \
      "echo cp /vagrant/jmxTransJsonFiles/* /var/lib/jmxtrans/ ; " \
      "docker pull nickstenning/graphite; " \
      "echo docker pull nickstenning/graphite; " \
      "sed -i '$ a\ sudo /etc/init.d/jmxtrans restart' /etc/rc.local;" \
      "echo sed add jmxtrans restart; " \
      "sed -i '$ a\ sudo docker run nickstenning/graphite' /etc/rc.local; " \
      "echo sed add docker run; "
    # Add Ubuntu raring backported kernel
    pkg_cmd << "apt-get update -qq; apt-get install -q -y linux-image-generic-lts-raring; "
    # Add guest additions if local vbox VM. As virtualbox is the default provider,
    # it is assumed it won't be explicitly stated.
    if ENV["VAGRANT_DEFAULT_PROVIDER"].nil? && ARGV.none? { |arg| arg.downcase.start_with?("--provider") }
      pkg_cmd << "apt-get install -q -y linux-headers-generic-lts-raring dkms; " \
        "echo 'Downloading VBox Guest Additions...'; " \
        "wget http://dlc.sun.com.edgesuite.net/virtualbox/4.2.12/VBoxGuestAdditions_4.2.12.iso; "
      # Prepare the VM to add guest additions after reboot and restart jmxtrans, since the variables for the tomcat server and graphite server are not picked up whem debian starts it up the first time
      pkg_cmd << "echo -e 'mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.2.12.iso /mnt\n" \
        "echo yes | /mnt/VBoxLinuxAdditions.run\numount /mnt\n" \
          "rm /root/guest_additions.sh; ' > /root/guest_additions.sh; " \
        "chmod 700 /root/guest_additions.sh; " \
        "sed -i -E 's#^exit 0#[ -x /root/guest_additions.sh ] \\&\\& /root/guest_additions.sh#' /etc/rc.local; " \
        "echo 'Installation of VBox Guest Additions is proceeding in the background.'; " \
        "echo '\"vagrant reload\" can be used in about 2 minutes to activate the new guest additions.'; " \
    end
    # Activate new kernel
    pkg_cmd << "shutdown -r +1; "
    config.vm.provision :shell, :inline => pkg_cmd
  end
end


# Providers were added on Vagrant >= 1.1.0
Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws.keypair_name = ENV["AWS_KEYPAIR_NAME"]
    override.ssh.private_key_path = ENV["AWS_SSH_PRIVKEY"]
    override.ssh.username = "ubuntu"
    aws.region = AWS_REGION
    aws.ami    = AWS_AMI
    aws.instance_type = "t1.micro"
  end

  config.vm.provider :rackspace do |rs|
    config.ssh.private_key_path = ENV["RS_PRIVATE_KEY"]
    rs.username = ENV["RS_USERNAME"]
    rs.api_key  = ENV["RS_API_KEY"]
    rs.public_key_path = ENV["RS_PUBLIC_KEY"]
    rs.flavor   = /512MB/
    rs.image    = /Ubuntu/
  end

  config.vm.provider :vmware_fusion do |f, override|
    override.vm.box = BOX_NAME
    override.vm.box_url = VF_BOX_URI
    override.vm.synced_folder ".", "/vagrant", disabled: true
    f.vmx["displayName"] = "docker"
  end

  config.vm.provider :virtualbox do |vb|
    config.vm.box = BOX_NAME
    config.vm.box_url = BOX_URI
  end
end

