## R CMD check results

This package vendors **Rust dependencies** resulting in a 13mb .xz file. Final installation size is 1.3mb

0 errors | 0 warnings | 1 note

* This is a new release.

## tarball size

This R package vendors its Rust dependencies. As such, the vendor.tar.xz file is fairly large. 
After compilation and installation, the R package is only 1.3mb on Mac. 

## Testing Environments

GitHub Actions:

- {os: macos-latest,   r: 'release'} 
- {os: windows-latest, r: 'release'}
- {os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'}
- {os: ubuntu-latest,   r: 'release'}
- {os: ubuntu-latest,   r: 'oldrel-1'}
- {os: ubuntu-latest,   r: 'oldrel-2'}

## Software Naming

ArcGIS is a brand name and not the name of a specific software. 

The phrase 'Geocoding service' refers to a spefic API which can be considered software. This is quoted in the DESCRIPTION file. Additionally, 'ArcGIS World Geocoder' and 'ArcGIS Enterprise' are products and software offering which is why they are quoted.

## Use of \dontrun

The use of dontrun is to ensure that the geocoding services are not called as they often require a user credential. And we do not want automatic testing to burden the public service.

## Resubmission

The CRAN url has been transitioned to use the canonical form package=pkgname