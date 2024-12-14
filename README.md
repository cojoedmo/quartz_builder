## Docker set-up

To build the image use the following command:
```shell
docker build -t quartz_builder:latest .
```

to run the docker:
```shell
docker run -d `
     -p 3000:3000
     -v C:\quartz_builder\obsidian:/vault `
     -v C:\quartz_builder\output:/output `
     -v C:\quartz_builder:/app `
     -e TIMER=0.1 `
     -e FOLDER=/test `
     quartz_builder:latest
```

The different variables are:
```
-p 3000:3000                           -> Expose the network port (optional)
-v C:\quartz_builder\obsidian:/vault `  -> The location of your obsidian vault
-v C:\quartz_builder\output:/output `   -> The location of the output folder
-v C:\quartz_builder:/app `            -> IMPORTANT! Use only for local dev. after having done npm install for faster iterations.
-e TIMER=0.1 `                         -> Time that has to be inbetween changes to the documents in the watched folders before we run the build pipeline
-e FOLDER=/test `                      -> The folder in your obsidian vault you want to output (default is /public, leave empty for root) 
quartz_builder:latest                          -> Name of the image you want to run
```

