## Docker set-up

To build the image use the following command:
```shell
docker build -t quartz_builder:latest .
```

to run the docker:
```shell
docker run -d `
     -v C:\docker_quartz\obsidian:/vault `
     -v C:\docker_quartz\output:/output `
     -e VAULT_DIR=/vault `
     -e OUTPUT_DIR=/output `
     -e TIMER=0.1 `
     -e FOLDER=/test `
     quartz:latest
```

The different variables are:
```
-v C:\docker_quartz\obsidian:/vault `  -> The location of your obsidian vault
-v C:\docker_quartz\output:/output `   -> The location of the output folder
-e VAULT_DIR=/vault `                  -> How we call the internal /vault folder (don't change)
-e OUTPUT_DIR=/output `                -> How we call the internal /output folder (don't change)
-e TIMER=0.1 `                         -> Time that has to be inbetween changes to the documents in the watched folders before we run the build pipeline
-e FOLDER=/test `                      -> The folder in your obsidian vault you want to output (default is /public, leave empty for root) 
quartz:latest                          -> Name of the image you want to run
```

