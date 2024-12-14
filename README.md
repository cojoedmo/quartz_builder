## Docker set-up

To build the image use the following command:
```shell
docker build -t quartz_builder:latest .
```

to run the docker:
```shell
docker run -d `
     -p 3000:3000
     -v C:\docker_quartz\obsidian:/vault `
     -v C:\docker_quartz\output:/output `
     -e TIMER=0.1 `
     -e FOLDER=/test `
     quartz_builder:latest
```

The different variables are:
```
-p 3000:3000                           -> Expose the network port (optional)
-v C:\docker_quartz\obsidian:/vault `  -> The location of your obsidian vault
-v C:\docker_quartz\output:/output `   -> The location of the output folder
-e TIMER=0.1 `                         -> Time that has to be inbetween changes to the documents in the watched folders before we run the build pipeline
-e FOLDER=/test `                      -> The folder in your obsidian vault you want to output (default is /public, leave empty for root) 
quartz_builder:latest                          -> Name of the image you want to run
```

