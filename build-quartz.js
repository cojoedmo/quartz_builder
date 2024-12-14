const chokidar = require('chokidar');
const exec = require('child_process').exec;
const fs = require('fs');

// Define the Vault directory to watch
const VAULT_DIR = process.env.VAULT_DIR || '/vault';
const OUTPUT_DIR = process.env.OUTPUT_DIR || '/output';
const TIMER = process.env.TIMER || 20;
const FOLDER = process.env.FOLDER || '/public';

// Function to execute a shell command
const runCommand = (cmd) => {
  return new Promise((resolve, reject) => {
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        // reject(`Error: ${error.message}`); //Because some libraries are deprecated it otherwise breaks
        resolve(`stderr: ${stderr}`);
        return;
      }
      if (stderr) {
        // reject(`stderr: ${stderr}`);
        resolve(`stderr: ${stderr}`);
        return;
      }
      resolve(stdout);
    });
  });
};

// Run the Quartz build process
const runBuild = async () => {
  try {
    console.log('Running Quartz build...');
    const pullResult = await runCommand('cd /quartz && git pull || git clone https://github.com/jackyzha0/quartz.git /quartz');
    console.log(pullResult);
    
    console.log(`Copying from ${VAULT_DIR}${FOLDER}/* to quartz.`)
    await runCommand(`rm -rf /quartz/content/*`); // Remove previous data
    await runCommand(`cp -r ${VAULT_DIR}${FOLDER}/* /quartz/content/`);
    await runCommand('cd /quartz')
    await runCommand('cd /quartz && npm install && npx quartz build');
    // await runCommand('npx quartz build');

    await runCommand(`rm -rf ${OUTPUT_DIR}/*`);  // Remove all files in the output directory
    await runCommand(`cp -r /quartz/public/* ${OUTPUT_DIR}`)
    console.log('Quartz build completed successfully!');
  } catch (error) {
    console.error('Build failed:', error);
  }
};


let directory = `${VAULT_DIR}${FOLDER}`
console.log(`The folder that will be monitored and published is: ${directory}`)

console.log(`Used to be: ${VAULT_DIR}`)
const watcher = chokidar.watch(directory, {
  ignored: /^\./, // Ignore dotfiles
  persistent: true,
  usePolling: true, // Poll instead of using native fs events (useful for Docker containers)
  interval: TIMER/10 * 60000, // Time in ms between each polling at 10 times the rate of update
  atomic: true, // Makes sure files are fully written before triggering an event
  recursive: true
});

let timeout;

// When a file is changed, added, or removed, start the timer
watcher.on('change', (path) => {
  console.log(`${path} has been changed. Waiting for ${TIMER}  minutes of inactivity...`);

  clearTimeout(timeout);
  timeout = setTimeout(runBuild, TIMER * 60 * 1000); // 5 minutes of inactivity
});

watcher.on('add', (path) => {
  console.log(`${path} has been added. Waiting for ${TIMER} minutes of inactivity...`);

  clearTimeout(timeout);
  timeout = setTimeout(runBuild, TIMER * 60 * 1000); // 5 minutes of inactivity
});

watcher.on('unlink', (path) => {
  console.log(`${path} has been removed. Waiting for ${TIMER} minutes of inactivity...`);

  clearTimeout(timeout);
  timeout = setTimeout(runBuild, TIMER * 60 * 1000); // 5 minutes of inactivity
});


// Start the watcher
watcher.on('ready', () => {
  console.log(`Watching for changes in ${VAULT_DIR}.2..`);
});

