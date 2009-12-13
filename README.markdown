Rails Metal for serving images from GridFS
------------------------------------------

The metal file catches routes for /images/grid_image/[path\_to\_grid\_fs\_file].

It also handles resizing using the following pattern:

/images/grid_image/resize\_100x100\_[path\_to\_grid\_fs\_file]
