# swiftref

`swiftref` is an OSX command-line utility for quickly Adding or Updating a 
[Swift ServiceStack Reference](http://docs.servicestack.net/swift-add-servicestack-reference) 
for consuming Typed Web Services in a Swift v3 Xcode project.

## Install swiftref

The easiest way to install `swiftref` is to download the OSX binary and save it to your `/usr/local/bin`:

     sudo curl https://raw.githubusercontent.com/ServiceStack/swiftref/master/dist/swiftref > /usr/local/bin/swiftref
     sudo chmod +x /usr/local/bin/swiftref

## Usage

### Add a new ServiceStack Reference:

To Add a new ServiceStack Reference you just need to provide the Base URL for the remote ServiceStack Service 
you wish to generate Typed Swift DTOs for:

    swiftref {BaseUrl}
    swiftref {BaseUrl} {FileName}

If the FileName is not provided it's inferred from the host name of the remote URL, e.g:

    swiftref http://techstacks.io

Which will download the Typed Swift DTOs for [techstacks.io](http://techstacks.io) and save them to `techstacks.dtos.swift` 
or if preferred, you can specify a different FileName to save to, e.g:

    swiftref http://techstacks.io TechStacks

Which will save the Typed Swift DTOs to `TechStacks.dtos.swift`.

`swiftref` also downloads [ServiceStack's Swift Client](https://github.com/ServiceStack/ServiceStack.Swift) 
and saves it to `JsonServiceClient.swift` which together with the Server DTOs contains all the dependencies required to 
consume Typed Web Services in Swift.

### Update an existing ServiceStack Reference:

To Update an existing ServiceStack Reference provide its Filename as the first argument:

    swiftref {FileName.dtos.swift}

As an example you can Update the Server DTOs added in the previous command with:

    swiftref TechStacks.dtos.swift

This will also include any 
[Customization Options](http://docs.servicestack.net/swift-add-servicestack-reference#swift-configuration) 
that were manually added.

## Learn

To learn more, see Documentation for [Swift Add ServiceStack Reference](http://docs.servicestack.net/swift-add-servicestack-reference).
