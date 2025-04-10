This is a maintenance release to ensure that the package passes checks on R-devel.

## R CMD check results

0 errors | 0 warnings | 0 note

## tarball size

This package vendors **Rust dependencies** resulting in a 13mb .xz file. Final installation size is 1.3mb


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

