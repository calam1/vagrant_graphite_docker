# Class: java
#
# The Java module allows Puppet to install the JDK/JRE
# and update the bashrc file to include java in the path.
#
# Provides: java::setup resource definition
#
# Parameters: ensure, source, deploymentdir, user, pathfile
#
class java{
    java::setup { "vagrant-jdk_7u25":
      ensure        => 'present',
      source        => 'jdk-7u25-linux-x64.gz',
      deploymentdir => '/usr/java',
      user          => 'root',
      pathfile      => '/home/vagrant/.bash_profile'
    }
}
