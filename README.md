# nixos-azure
All NixOS configuration for generating and utilizing NixOS VM Images on Azure.

## Creating Images

If you'd like practical examples of how to generate VM Images using NixOS Generate, please refer to [the docs here](docs/create-images.md).

## Uploading images/disks to Azure

if you'd like to know more about how to upload images to Azure:
- [https://learn.microsoft.com/en-us/powershell/module/az.compute/add-azimagedatadisk](https://learn.microsoft.com/en-us/powershell/module/az.compute/add-azimagedatadisk)

If you'd like to know more about how to upload (managed) disks to Azure:
- [https://learn.microsoft.com/en-us/azure/virtual-machines/windows/disks-upload-vhd-to-managed-disk-powershell](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/disks-upload-vhd-to-managed-disk-powershell)

## Various Azure background information

In order to understand all of the Azure related background information related to creating the NixOS VM Image, please reference this collection here:
- [https://learn.microsoft.com/en-us/collections/4w5wfxt2xjj043](https://learn.microsoft.com/en-us/collections/4w5wfxt2xjj043)

This collection has several Microsoft Learn documents needed to determine disk sizing, image uploading processes, Bastion for Developers, and more.
