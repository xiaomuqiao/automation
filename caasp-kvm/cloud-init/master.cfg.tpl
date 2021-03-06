#cloud-config

# set locale
locale: en_GB.UTF-8

# set timezone
timezone: Etc/UTC

# Set hostname and FQDN
# TODO: We only generate 1 cloud-init, so can't include the index here?
#hostname: caasp-master-INDEX-HERE
#fqdn: caasp-master-INDEX-HERE.devenv.caasp.suse.net

# set root password
chpasswd:
  list: |
    root:linux
  expire: False

ssh_authorized_keys:
 - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2G7k0zGAjd+0LzhbPcGLkdJrJ/LbLrFxtXe+LPAkrphizfRxdZpSC7Dvr5Vewrkd/kfYObiDc6v23DHxzcilVC2HGLQUNeUer/YE1mL4lnXC1M3cb4eU+vJ/Gyr9XVOOReDRDBCwouaL7IzgYNCsm0O5v2z/w9ugnRLryUY180/oIGeE/aOI1HRh6YOsIn7R3Rv55y8CYSqsbmlHWiDC6iZICZtvYLYmUmCgPX2Fg2eT+aRbAStUcUERm8h246fs1KxywdHHI/6o3E1NNIPIQ0LdzIn5aWvTCd6D511L4rf/k5zbdw/Gql0AygHBR/wnngB5gSDERLKfigzeIlCKf Unsafe Shared Key

# set as cluster member
suse_caasp:
  role: cluster
  admin_node: ${admin_ip}

bootcmd:
  - ip link set dev eth0 mtu 1400

final_message: "The system is finally up, after $UPTIME seconds"
