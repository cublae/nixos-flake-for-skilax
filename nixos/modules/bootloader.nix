{ pkgs
, ...
}: 
{
  boot = {
    supportedFilesystems = [ "ntfs" ];
    kernelParams = [ "nvidia_drm.fbdev=1" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}