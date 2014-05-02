# README:
#
# For this test to work you must do the following
# - Create a directory called files in module java (this module)
# - Download jdk or jre from Oracle's website and put in the files directory.
#   JDK or JRE is not included in this module by default because of Oracle's
#   licensing
# Note: Parameter source should be the exact name of the downloaded JDK or JRE archive file
#
java::setup { 'jdk_6u31':
  ensure        => present,
  source        => 'jdk-6u31-linux-x64.bin',
  deploymentdir => '/opt/jdk',
  user          => 'root',
}